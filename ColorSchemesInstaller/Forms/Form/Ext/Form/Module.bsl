#if not WebClient then

&AtClient
var AppDataDir, LastColor;

#Region FormEventHandlers

&AtServer
procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	This = FormAttributeToValue("Object");
	DefaultSchemes		= This.GetTemplate("DefaultSchemes").GetText();
	Des_Template		= This.GetTemplate("Designer_HTML").GetText();
	Designer_IDEA		= FromJSON(This.GetTemplate("Designer_IDEA").GetText());
	Designer_Sublime	= FromJSON(This.GetTemplate("Designer_Sublime").GetText());
	Designer_Sublimes	= FromJSON(This.GetTemplate("Designer_Sublimes").GetText());
	EDT_Template		= This.GetTemplate("EDT_HTML").GetText();
	EDT_IDEA			= FromJSON(This.GetTemplate("EDT_IDEA").GetText(), true);
	EDT_Sublime			= FromJSON(This.GetTemplate("EDT_Sublime").GetText(), true);
	EDT_Sublimes		= FromJSON(This.GetTemplate("EDT_Sublimes").GetText(), true);
	IDEA_Themes_List	= This.GetTemplate("IDEA_Themes_List").GetText();
	
	Map = new Map;
	Map.Insert("Keywords", "Red");
	Map.Insert("Numerics", "DimGray");
	Map.Insert("Strings", "Black");
	Map.Insert("Dates", "Gray");
	Map.Insert("Identifiers", "Blue");
	Map.Insert("Operators", "Orange");
	Map.Insert("Comments", "Green");
	Map.Insert("Preprocessor", "Maroon");
	Map.Insert("Others", "Yellow");
	Map.Insert("Background", "White");
	Map.Insert("CurrentToken", "Gainsboro");
	Map.Insert("CurrentSelection", "LightGray");
	Map.Insert("PairLexeme", "Silver");
	Map.Insert("SearchResult", "DarkGray");

	for each Entry in Designer_IDEA do
		NewLine = Des_ColorsTable.Add();
		NewLine.Name1C = Entry.Key;
		NewLine.NameIDEA = Entry.Value;
		NewLine.NameSublime = Designer_Sublime[Entry.Key];
		NewLine.NameSublimes = Designer_Sublimes[Entry.Key];
		NewLine.DefaultColor = Map[NewLine.Name1C];
	enddo;
	
	Map = new Map;
	Map.Insert("BSL_Keywords", "Red");
	Map.Insert("Numbers", "DimGray");
	Map.Insert("Strings", "Black");	
	Map.Insert("Others", "Blue");
	Map.Insert("Comment", "Green");
	Map.Insert("Brackets", "Gold");
	Map.Insert("Operators", "Orange");
	Map.Insert("Preprocessor", "Maroon");
	Map.Insert("Builtinfunction", "Purple");
	Map.Insert("BSL_Pragmas", "Brown");
	Map.Insert("Background", "White");
	Map.Insert("lineNumberColor", "Gray");
	Map.Insert("currentLineColor", "Gainsboro");
	Map.Insert("occurrenceIndicationColor", "LightGray");
	Map.Insert("SelectionForeground", "Yellow");
	Map.Insert("SelectionBackground", "RoyalBlue");
	
	for each Entry in EDT_IDEA do
		Parts = StrSplit(Entry.Key, ".");
		NewLine = EDT_ColorsTable.Add();
		NewLine.FullName1C = Entry.Key;
		NewLine.Name1C = Parts[Parts.UBound()];
		NewLine.NameIDEA = Entry.Value;
		NewLine.NameSublime = EDT_Sublime[NewLine.FullName1C];
		NewLine.NameSublimes = EDT_Sublimes[NewLine.FullName1C];
		NewLine.DefaultColor = Map[NewLine.Name1C];
	enddo;
	
	BackgroundColors.Add("Background");
	BackgroundColors.Add("CurrentToken");
	BackgroundColors.Add("CurrentSelection");
	BackgroundColors.Add("PairLexeme");
	BackgroundColors.Add("SearchResult");
	BackgroundColors.Add("AutoAssistBackground");	
	BackgroundColors.Add("occurrenceIndicationColor");
	BackgroundColors.Add("currentLineColor");
	BackgroundColors.Add("currentIPColor");
	BackgroundColors.Add("SelectionBackground");
	
	EDT_SyntaxPrefsFilePath = "\.metadata\.plugins\org.eclipse.core.runtime\.settings\com._1c.g5.v8.dt.bsl.ui.prefs";
	EDT_EditorPrefsFilePath = "\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.ui.editors.prefs";
	EDT_TokenStylesPrefix = "com._1c.g5.v8.dt.bsl.Bsl.syntaxColorer.";
	
endprocedure

&AtClient
procedure OnOpen(Cancel)
	
	FindColorSchemeFilesInLocalDir();
	BeginGettingUserDataWorkDir(new NotifyDescription("AfterGettingUserDataWorkDir", ThisObject));
	                
endprocedure

#EndRegion

#Region ItemsEventHandlers

#Region GroupSources

&AtClient
procedure GroupSourcesOnCurrentPageChange(Item, CurrentPage)
	
	if CurrentPage = Items.GroupLocalDir then
		LoadLocalScheme();
	elsif CurrentPage = Items.GroupSublime then
		if tmThemeGallery.Count() = 0 then
			FillThemeGalleryByAPI();
		else
		 	LoadSublimeScheme();	
		endif;
	elsif CurrentPage = Items.GroupIDEA then
		if ColorSchemesDirPath = "" then
			Items.GroupSources.CurrentPage = Items.GroupLocalDir;
			MessageToUser("Заполните путь к каталогу с цветовыми схемами", "ColorSchemesDirPath");
			return;
		endif;
		if ColorThemes.Count() = 0 then
			FillColorThemesFromList();
		else
			LoadIDEAScheme();
		endif;
	endif;
	
endprocedure

&AtClient
procedure LocalSchemesOnActivateRow(Item)
	
	AttachIdleHandler("LoadLocalScheme", 0.1, true);
	
endprocedure

&AtClient
procedure ColorThemesOnActivateRow(Item)
	
	AttachIdleHandler("LoadIDEAScheme", 0.1, true);
	
endprocedure

&AtClient
procedure tmThemeGalleryOnActivateRow(Item)
	
	AttachIdleHandler("LoadSublimeScheme", 0.1, true);
	
endprocedure

&AtClient
procedure LinkClick(Item)
	
	GotoURL(Item.Title);
	
endprocedure

#EndRegion

&AtClient
procedure HTMLOnClick(Item, EventData, StandardProcessing)
	
	Parts = StrSplit(Item.Name, "_");
	Class = EventData.Element.className;
	Class = Mid(Class, StrFind(Class, " ") + 1);
	FoundItem = Items.Find(Parts[0] + "_" + Class);
	if FoundItem <> undefined then
		CurrentItem = FoundItem;
	endif;
	
endprocedure

&AtClient
procedure ColorSchemesDirPathStartChoice(Item, ChoiceData, StandardProcessing)
	
	StandardProcessing = false;
	Dialog = new FileDialog(FileDialogMode.ChooseDirectory);
	Dialog.Title = "Выберите каталог с цветовыми схемами";
	Dialog.Show(new NotifyDescription("ColorSchemesDirPathChoice", ThisObject));
	
endprocedure

&AtClient
procedure ColorSchemesDirPathOnChange(Item)
	
	FindColorSchemeFilesInLocalDir();
	
endprocedure

&AtClient
procedure ColorStartChoice(Item, ChoiceData, StandardProcessing)
	
	LastColor = ThisObject[Item.Name];
	
EndProcedure

&AtClient
procedure ColorOnChange(Item)
	
	CurrentColor = ThisObject[Item.Name];
	if CurrentColor.Type = ColorType.WebColor then
		FormattedDocument = new FormattedDocument; 
		FormattedDocument.Add("Color", Type("FormattedDocumentText"));
		FormattedDocument.Items[0].Items[0].BackColor = CurrentColor; 
		ThisObject[Item.Name] = FormattedDocument.Items[0].Items[0].BackColor;
	elsif CurrentColor.Type <> ColorType.Absolute then
		ThisObject[Item.Name] = LastColor;
		MessageToUser("К сожалению, выбор цветов из стиля не поддерживается. Выберите web-цвет или задайте RGB вручную", Item.Name);
	endif;
	
	if StringStartsWith(Item.Name, "Des") then
		RefreshHTML("Des");
	else
		RefreshHTML("EDT");
	endif;			
	
endprocedure

&AtClient
procedure ColorTuning(Item, Direction, StandardProcessing)
	
	Color = ThisObject[Item.Name];
	if Direction > 0 and Color.R <= 250 and Color.G <= 250 and Color.B <= 250
		or Direction < 0 and Color.R >= 5 and Color.G >= 5 and Color.B >= 5 then
		ThisObject[Item.Name] = new Color(Color.R + Direction * 5, Color.G + Direction * 5, Color.B + Direction * 5);
		ColorOnChange(Item);
	endif;
	
endprocedure

&AtClient
procedure EDT_WorkspacePathStartChoice(Item, ChoiceData, StandardProcessing)
	
	StandardProcessing = false;
	Dialog = new FileDialog(FileDialogMode.ChooseDirectory);
	Dialog.Title = "Выберите каталог рабочей области EDT";
	Dialog.Show(new NotifyDescription("EDT_WorkspacePathChoice", ThisObject));
	
endprocedure

#EndRegion

#Region CommandsEventHandlers

&AtClient
procedure OpenLinksForm(Command)
	
	OpenForm("ExternalDataProcessor.ColorSchemesInstaller.Form.FormLinks",,,,,, undefined, FormWindowOpeningMode.LockWholeInterface);
	
endprocedure

&AtClient
procedure RereadLocalDir(Command)
	
	FindColorSchemeFilesInLocalDir();
	
endprocedure

&AtClient
procedure ColorThemesSortByTitle(Command)
	
	ColorThemes.Sort("Title");
	
endprocedure

&AtClient
procedure ColorThemesSortByColor(Command)
	
	ColorThemes.Sort("Light Desc, Downloads Desc");
	
endprocedure

&AtClient
procedure ColorThemesSortByDownloads(Command)
	
	ColorThemes.Sort("Downloads Desc");
	
endprocedure

&AtClient
procedure tmThemeGallerySortByName(Command)
	
	tmThemeGallery.Sort("Name");
	
endprocedure

&AtClient
procedure tmThemeGallerySortByColor(Command)
	
	tmThemeGallery.Sort("Light Desc, Name");
	
endprocedure

&AtClient
procedure InvertColors(Command)
	
	IDE = ?(Items.GroupIDEs.CurrentPage = Items.GroupDesigner, "Des_", "EDT_");
	for each Color in ThisObject[IDE + "ColorsTable"] do
		RGB = ThisObject[IDE + Color.Name1C];
		ThisObject[IDE + Color.Name1C] = new Color(255 - RGB.R, 255 - RGB.G, 255 - RGB.B);
	enddo;
	RefreshHTML(IDE);
	
endprocedure

&AtClient
procedure SaveToFile(Command)
	
	if ColorSchemesDirPath = "" then
		MessageToUser("Заполните путь к каталогу с цветовыми схемами", "ColorSchemesDirPath");
		return;
	endif;
	
	Dialog = new FileDialog(FileDialogMode.Save);
	Dialog.Directory = ColorSchemesDirPath;
	Dialog.Filter = "Файлы настроек CSI|*.csi";
	Dialog.Title = "Введите имя файла для сохранения настроек";
	Dialog.FullFileName = ColorSchemesDirPath + "\" + Title;
	if not StrEndsWith(Title, ".csi") then
		Dialog.FullFileName = Dialog.FullFileName + ".csi";
	endif;
	Dialog.Show(new NotifyDescription("WriteSettingsToFile", ThisObject));
	
endprocedure

&AtClient
procedure InstallToDesigner(Command)
	
	Dialog = new FileDialog(FileDialogMode.Open);
	Dialog.Directory = AppDataDir;
	Dialog.Filter = "Файл настроек|1cv8.pfl";
	Dialog.Title = "Выберите файл настроек конфигуратора";
	Dialog.Show(new NotifyDescription("InstallToDesignerAfterChoosingFile", ThisObject));
	
endprocedure

&AtClient
procedure InstallToEDT(Command)
	
	if EDT_WorkspacePath = "" then
		ShowMessageBox(, "Заполните путь к рабочей области EDT");
		return;
	endif;
	
	ShowQueryBox(
		new NotifyDescription("InstallToEDTAfterAccept", ThisObject),
		"Закройте EDT. Будут перезаписаны файлы com._1c.g5.v8.dt.bsl.ui.prefs и org.eclipse.ui.editors.prefs.",
		QuestionDialogMode.OKCancel);
	
endprocedure

#EndRegion

#Region Internal

&AtClient
procedure AfterCheckingFileExistence(Exist, Parameters) export
	
	if Exist then
		TextReader = new TextReader(Parameters.FileName);
		Text = TextReader.Read();                                               
		TextReader.Close();
	else
		Text = "";
	endif;

	NotifyDescription = new NotifyDescription(Parameters.AfterReadingProcedure, ThisObject, Parameters.FileName);
	ExecuteNotifyProcessing(NotifyDescription, Text);

endprocedure

&AtClient
procedure AfterGettingUserDataWorkDir(UserDataWorkDir, AdditionalParameters) export
	
	AppDataDir = "";
	for each Dir in StrSplit(UserDataWorkDir, "\") do
		AppDataDir = AppDataDir + Dir + "\";
		if StringStartsWith(Lower(Dir), "1cv8") then
			break;
		endif;
	enddo;
	
endprocedure

&AtClient
procedure ColorSchemesDirPathChoice(SelectedFiles, AdditionalParameters) export
	
	if (SelectedFiles = undefined) then
		return;
	endif;
	ColorSchemesDirPath = SelectedFiles[0];
	FindColorSchemeFilesInLocalDir();
	
endprocedure

&AtClient
procedure EDT_WorkspacePathChoice(SelectedFiles, AdditionalParameters) export
	
	if (SelectedFiles = undefined) then
		return;
	endif;
	EDT_WorkspacePath = SelectedFiles[0];
	
endprocedure

&AtClient
procedure FillLocalSchemes(FilesFound, AdditionalParameters) export
	
	LocalSchemes.Add().Name = "<Current>";
	LocalSchemes.Add().Name = "<Default>";
	
	Extensions = new Array;
	Extensions.Add(".csi");
	Extensions.Add(".jar");
	Extensions.Add(".icls");
	Extensions.Add(".xml");
	Extensions.Add(".tmtheme");
	
	for each ColorFile in FilesFound do		
		if Extensions.Find(Lower(ColorFile.Extension)) = undefined then
			continue;
		endif;
		FillPropertyValues(LocalSchemes.Add(), ColorFile);
	enddo;

endprocedure

&AtClient
procedure WriteSettingsToFile(SelectedFiles, AdditionalParameters) export
	
	if (SelectedFiles = undefined) then
		return;
	endif;
	
	Settings = new Structure;
	
	Settings.Insert("DesignerColors", new Array);	
	for each Color in Des_ColorsTable do
		ColorValue = RGBtoHEX(ThisObject["Des_" + Color.Name1C]);
		Settings.DesignerColors.Add(new Structure("Name,Color", Color.Name1C, ColorValue));
	enddo;
	
	Settings.Insert("EDTColors", new Array);	
	for each Color in EDT_ColorsTable do
		ColorValue = RGBtoHEX(ThisObject["EDT_" + Color.Name1C]);
		Settings.EDTColors.Add(new Structure("Name,Color", Color.Name1C, ColorValue));
	enddo;
	
	TextWriter = new TextWriter(SelectedFiles[0]);
	TextWriter.Write(ToJSON(Settings));
	TextWriter.Close();
	
	FindColorSchemeFilesInLocalDir();
	
endprocedure

&AtClient
procedure InstallToDesignerAfterChoosingFile(SelectedFiles, AdditionalParameters) export
	
	if (SelectedFiles <> undefined) then
		ReadTextFile(SelectedFiles[0], "WriteToDesignerFile");
	endif;

endprocedure

&AtClient
procedure InstallToEDTAfterAccept(Result, AdditionalParameters) export
	
	if (Result = DialogReturnCode.OK) then
		ReadTextFile(EDT_WorkspacePath + EDT_SyntaxPrefsFilePath, "WriteToEDTSyntaxPrefsFile");
		ReadTextFile(EDT_WorkspacePath + EDT_EditorPrefsFilePath, "WriteToEDTEditorPrefsFile");
	endif;

endprocedure

&AtClient
procedure WriteToDesignerFile(Text, FileName) export
		
	if StrFind(Text, "ModuleColorCategory") = 0 then
		
		//Если в файле еще нет блока описания цветовой схемы
		Pos = StrFind(Text, "{", , , 3);
		Begin = "{
		|{""""},
		|{
		|{""ModuleColorCategory"",
		|{";	
		End = """""},
		|{
		|{""""}
		|}
		|},"
		+ Mid(Text, Pos+1); 			
		BlockText = "";
		for each Color in Des_ColorsTable do
			ColorText = RGBtoDEC(ThisObject["Des_" + Color.Name1C]);
			BlockText = BlockText + """" + Color.Name1C + """," + ColorText + ",";
		enddo;			
		Text = Begin + BlockText + End;
		
	else 
		
		for each Color in Des_ColorsTable do 
			KeyPos = StrFind(Text, """" + Color.Name1C + """");
			ColorText = RGBtoDEC(ThisObject["Des_" + Color.Name1C]);
			if KeyPos <> 0 then 
				BeginPos = StrFind(Text, "{", , KeyPos, 1);
				EndPos = StrFind(Text, "}", , BeginPos, 3);
				Begin = Left(Text, BeginPos-1);
				End = Mid(Text, EndPos+1);
				Text = Begin + ColorText + End; 
			else 
				BlockKeyPos = StrFind(Text, "ModuleColorCategory");
				BeginPos = StrFind(Text, "{", , BlockKeyPos, 1);
				Begin = Left(Text, BeginPos+1);
				End = Mid(Text, BeginPos+1);
				BlockText = """" + Color.Name1C + """," + ColorText + ",";
				Text = Begin + BlockText + End; 
			endif;
		enddo;
		
	endif;
	
	TextWriter = new TextWriter(FileName);
	TextWriter.Write(Text);
	TextWriter.Close();

	ShowMessageBox(, "Цветовая схема успешно изменена, перезапустите конфигуратор");

endprocedure

&AtClient
procedure WriteToEDTSyntaxPrefsFile(Text, FileName) export

	TextLines = new ValueList();
	for LineNumber = 1 to StrLineCount(Text) do
		CurrentLine = StrGetLine(Text, LineNumber);
		if CurrentLine = "\u00EF\u00BB\u00BF=" then
			continue;
		endif;
		Pos = StrFind(CurrentLine, "=");
		TextLines.Add(Left(CurrentLine, Pos-1), Mid(CurrentLine, Pos+1)); 		
	enddo;

	for each Color in EDT_ColorsTable do
		if not StringStartsWith(Color.FullName1C, "tokenStyles") then
			continue;
		endif;
		FullName1C = StrReplace(Color.FullName1C, "Builtinfunction", "Builtin\ function");
		FullName1C = EDT_TokenStylesPrefix + FullName1C + ".color";
		RGB = ThisObject["EDT_" + Color.Name1C];
		SetPresentationToListValue(TextLines, FullName1C, StrTemplate("%1,%2,%3", RGB.R, RGB.G, RGB.B));
	enddo;
	
	NewText = "";
	TextLines.SortByValue();
	for each Line in TextLines do
		NewText = NewText + Chars.LF + Line.Value + "=" + Line.Presentation;
	enddo;
	
	TextWriter = new TextWriter(FileName);
	TextWriter.Write(NewText);
	TextWriter.Close();
	MessageToUser("Настройки записаны в файл " + FileName);

endprocedure

&AtClient
procedure WriteToEDTEditorPrefsFile(Text, FileName) export

	TextLines = new ValueList;
	for LineNumber = 1 to StrLineCount(Text) do
		CurrentLine = StrGetLine(Text, LineNumber);
		if CurrentLine = "\u00EF\u00BB\u00BF=" then
			continue;
		endif;
		Pos = StrFind(CurrentLine, "=");
		TextLines.Add(Left(CurrentLine, Pos-1), Mid(CurrentLine, Pos+1)); 		
	enddo;

	SystemDefaults = new Array;
	SystemDefaults.Add("Background");
	SystemDefaults.Add("Foreground");
	SystemDefaults.Add("SelectionBackground");
	SystemDefaults.Add("SelectionForeground");
	SystemDefaults.Add("hyperlinkColor");

	for each Color in EDT_ColorsTable do
		if StringStartsWith(Color.FullName1C, "tokenStyles") then
			continue;
		endif;
		RGB = ThisObject["EDT_" + Color.Name1C];
		SetPresentationToListValue(TextLines, Color.FullName1C, StrTemplate("%1,%2,%3", RGB.R, RGB.G, RGB.B));
		if SystemDefaults.Find(Color.Name1C) <> undefined then
			SetPresentationToListValue(TextLines, Color.FullName1C + ".SystemDefault", "false");
		endif;
	enddo;
	
	NewText = "";
	TextLines.SortByValue();
	for each Line in TextLines do
		NewText = NewText + Chars.LF + Line.Value + "=" + Line.Presentation;
	enddo;
	
	TextWriter = new TextWriter(FileName);
	TextWriter.Write(NewText);
	TextWriter.Close();
	MessageToUser("Настройки записаны в файл " + FileName);

endprocedure

&AtClient
procedure FillColorThemesFromListAfterCheckingDir(Exist, AdditionalParameters) export
	
	if not Exist then
		Zip = new ZipFileReader(IDEA_Themes().OpenStreamForRead());
		Zip.ExtractAll(IDEAThemesDirPath);
	endif;
	
	FillColorThemesFromListAtServer();
	
endprocedure

#Region ParsingSchemes

&AtClient
procedure ParseDesignerPflFile(Text, FileName) export
		
	if StrFind(Text, "ModuleColorCategory") = 0 then
		return;		
	endif;
	
	for each Line in Des_ColorsTable do
		
		ColorPos = StrFind(Text, """" + Line.Name1C + """");
		if ColorPos = 0 then
			continue;
		endif;
		
		BeginPos = StrFind(Text, "{", , ColorPos, 3) + 1;
		EndPos = StrFind(Text, "}", , BeginPos, 1);
		ColorValue = Mid(Text, BeginPos, EndPos - BeginPos); 
		
		if Number(ColorValue) > 0 then
			ThisObject["Des_" + Line.Name1C] = DECtoRGB(ColorValue);
		endif;
		
	enddo;
	
	RefreshHTML("Des");
	
endprocedure

&AtClient
procedure ParseCSIFile(Text, FileName) export
	
	Settings = FromJSON(Text);
	ClearColors();
	
	if Settings.Property("DesignerColors") then
		for each Color in Settings.DesignerColors do
			SetColor("Des_" + Color.Name, Color.Color);
		enddo;
	endif;
	
	if Settings.Property("EDTColors") then
		for each Color in Settings.EDTColors do
			SetColor("EDT_" + Color.Name, Color.Color);
		enddo;
	endif;
	
	SetDefaultColors("Des", Des_Identifiers);
	SetDefaultColors("EDT", EDT_Foreground);	
	RefreshHTML("Des");
	RefreshHTML("EDT");

endprocedure

&AtClient
procedure ParseSublimeText(val Text, FileName = "") export
	
	StringXML = "";
	
	ThisIsComment = false;
	for LineNumber = 1 to StrLineCount(Text) do
		CurrentLine = StrGetLine(Text, LineNumber);
		CurrentLine = StrReplace(CurrentLine, "&", "and");
		if StringStartsWith(CurrentLine, "<!--") then
			ThisIsComment = true;
		endif;
		if not ThisIsComment then
			StringXML = StringXML + CurrentLine + Chars.LF;
		endif;
		if StrEndsWith(CurrentLine, "-->") then
			ThisIsComment = false;
		endif;
	enddo;
	
	ColorScheme = ReadSchemeXML(StringXML);
	if ColorScheme = undefined then
		return;
	endif;
	ClearColors();
	
	Dict = ColorScheme.dict;
	if TypeOf(Dict) = Type("XDTOList") then
		Dict = Dict[0];
	endif;
		
	ColumnName = "NameSublime";
	for Ind = 1 to 10 do
		StringList = Dict.array.dict[Ind].string;
		if TypeOf(StringList) = Type("XDTOList") then
			if StringList[0] = "Text" then
				ColumnName = "NameSublimes";
			endif;
			break;
		endif;
	enddo;
	
	if XDTOHasProperty(Dict, "dict") then
		for Ind = 0 to Dict.dict.key.Count() - 1 do
			SetColorFromSource(ColumnName, Dict.dict.key[Ind], Dict.dict.string[Ind]);
		enddo;
	endif;
	
	for each Entry in Dict.array.dict do
		if Entry.key = "settings" then
			for Ind = 0 to Entry.dict.key.Count() - 1 do
				SetColorFromSource(ColumnName, Entry.dict.key[Ind], Entry.dict.string[Ind]);
			enddo;
		else
			if not XDTOHasProperty(Entry, "dict")
				or not XDTOHasProperty(Entry.dict, "key")
				or TypeOf(Entry.string) <> Type("XDTOList") then
				continue;
			endif;
			if TypeOf(Entry.dict.key) = Type("XDTOList") then
				for Ind = 0 to Entry.dict.key.Count() - 1 do
					if TypeOf(Entry.string[0]) = Type("String") then
						ColumnValue = Entry.string[0] + "." + Entry.dict.key[Ind];
						SetColorFromSource(ColumnName, ColumnValue, Entry.dict.string[Ind]);
					endif;
				enddo;
			else
				SetColorFromSource(ColumnName, Entry.string[0] + "." + Entry.dict.key, Entry.dict.string);
			endif;
		endif;
	enddo;
	
	SetDefaultColors("Des", Des_Identifiers);
	SetDefaultColors("EDT", EDT_Foreground);	
	RefreshHTML("Des");
	RefreshHTML("EDT");

endprocedure

&AtClient
procedure ParseEDTEditorPrefs(Text, FileName) export
	
	for LineNumber = 1 to StrLineCount(Text) do
		Parts = StrSplit(StrGetLine(Text, LineNumber), "=");
		Colors = EDT_ColorsTable.FindRows(new Structure("FullName1C", Parts[0]));
		for each Color in Colors do
			ThisObject["EDT_" + Color.Name1C] = Eval("new Color(" + Parts[1] + ")");
		enddo;
	enddo;

	RefreshHTML("EDT");
	
endprocedure

&AtClient
procedure ParseEDTSyntaxPrefs(Text, FileName) export
	
	for LineNumber = 1 to StrLineCount(Text) do
		Parts = StrSplit(StrGetLine(Text, LineNumber), "=");
		FullName1C = StrReplace(StrReplace(StrReplace(Parts[0], EDT_TokenStylesPrefix, ""), ".color", ""), "\ ", "");
		Colors = EDT_ColorsTable.FindRows(new Structure("FullName1C", FullName1C));
		for each Color in Colors do
			ThisObject["EDT_" + Color.Name1C] = Eval("new Color(" + Parts[1] + ")");
		enddo;
	enddo;

	RefreshHTML("EDT");
	
endprocedure

#EndRegion

#EndRegion

#Region Private

&AtClient
procedure ReadTextFile(FileName, AfterReadingProcedure)

	File = new File(FileName);
	AdditionalParameters = new Structure("FileName,AfterReadingProcedure", FileName, AfterReadingProcedure);
	File.BeginCheckingExistence(new NotifyDescription("AfterCheckingFileExistence", ThisObject,  AdditionalParameters));

endprocedure

&AtClient
procedure FindColorSchemeFilesInLocalDir()
	
	LocalSchemes.Clear();
	BeginFindingFiles(new NotifyDescription("FillLocalSchemes", ThisObject), ColorSchemesDirPath, "*.*", false);
	
endprocedure

&AtClient
procedure FillColorThemesFromList()
	
	IDEAThemesDirPath = ColorSchemesDirPath + "\IDEA_Themes";
	ThemesDir = new File(IDEAThemesDirPath);
	ThemesDir.BeginCheckingExistence(New NotifyDescription("FillColorThemesFromListAfterCheckingDir", ThisForm));
	
endprocedure

&AtServer
procedure FillColorThemesFromListAtServer()
	
	for LineNum = 1 to StrLineCount(IDEA_Themes_List) do
		Fields = StrSplit(StrGetLine(IDEA_Themes_List, LineNum), ",");
		Back = HEXtoRGB(Fields[2]);
		NewRow = ColorThemes.Add();
		NewRow._id = Fields[0];
		NewRow.Title = Fields[3];
		NewRow.Downloads = Fields[1];
		NewRow.FileName = ThemeFileName(Fields[3]);
		NewRow.Light = (Back.R + Back.G + Back.B) > 128 * 3;
	enddo;
	
	ColorThemes.Sort("Downloads Desc");
	
endprocedure

&AtServerNoContext
function ThemeFileName(Title)
	
	SpecSymbols = new Map;
	SpecSymbols.Insert(" ", "%20");
	SpecSymbols.Insert("'", "%27");
	SpecSymbols.Insert("(", "%28");
	SpecSymbols.Insert(")", "%29");
	
	FileName = EncodeString(Title, StringEncodingMethod.URLEncoding);
	for each Symb in SpecSymbols do
		FileName = StrReplace(FileName, Symb.Value, Symb.Key);
	enddo;
	
	return FileName + ".xml";

endfunction

&AtServer
function IDEA_Themes()
	
	return FormAttributeToValue("Object").GetTemplate("IDEA_Themes");
	
endfunction

&AtClient
procedure FillThemeGalleryByAPI()
	
	HTTPConnection = new HTTPConnection("tmtheme-editor.herokuapp.com",,,,,,new OpenSSLSecureConnection);
	HTTPRequest = new HTTPRequest("gallery.json");
	HTTPRequest.headers.insert("Accept", "application/json, text/plain, */*");
	HTTPResponse = HTTPConnection.Get(HTTPRequest);
	
	for each Theme in FromJSON(HTTPResponse.GetBodyAsString()) do
		if not StringStartsWith(Theme.name, "Base16") then
			FillPropertyValues(tmThemeGallery.Add(), Theme);
		endif;
	enddo;

endprocedure

&AtClient
procedure LoadLocalScheme()
	
	CurrentData = Items.LocalSchemes.CurrentData;
	if CurrentData = undefined then
		return;
	endif;
	Title = CurrentData.Name;
	
	if Title = "<Current>" then
		ReadTextFile(AppDataDir + "1cv8.pfl", "ParseDesignerPflFile");
		if ValueIsFilled(EDT_WorkspacePath) then
			ReadTextFile(EDT_WorkspacePath + EDT_SyntaxPrefsFilePath, "ParseEDTSyntaxPrefs");
			ReadTextFile(EDT_WorkspacePath + EDT_EditorPrefsFilePath, "ParseEDTEditorPrefs");
		endif;
		return;
	endif;
	
	if Title = "<Default>" then
		ParseCSIFile(DefaultSchemes, "");
		return;
	endif;
	
	ColorSchemeFilePath = Lower(CurrentData.FullName);
	if StrEndsWith(ColorSchemeFilePath, "tmtheme") then
		ReadTextFile(ColorSchemeFilePath, "ParseSublimeText");
	elsif StrEndsWith(ColorSchemeFilePath, "csi") then
		ReadTextFile(ColorSchemeFilePath, "ParseCSIFile");
	else
		ReadIDEAFile(ColorSchemeFilePath);
	endif;
	
endprocedure

&AtClient
procedure LoadIDEAScheme()
	
	CurrentData = Items.ColorThemes.CurrentData;
	if CurrentData = undefined then
		return;
	endif;
	
	Title = CurrentData.Title;
	ReadIDEAFile(IDEAThemesDirPath + "\" + CurrentData.FileName);
		
endprocedure

&AtClient
procedure LoadSublimeScheme()
	
	CurrentData = Items.tmThemeGallery.CurrentData;
	if CurrentData = undefined then
		return;
	endif;
	
	Title = CurrentData.Name;
	
	Server = "raw.githubusercontent.com";
	HTTPConnection = new HTTPConnection(Server,,,,,,new OpenSSLSecureConnection);
	HTTPRequest = new HTTPRequest(StrReplace(CurrentData.URL, "https://" + Server, ""));
	HTTPResponse = HTTPConnection.Get(HTTPRequest);
	
	if HTTPResponse.StatusCode = 404 then
		MessageToUser("Цветовая схема по указанному адресу не найдена", "tmThemeGallery");
		return;
	endif;
	
	ParseSublimeText(HTTPResponse.GetBodyAsString());
	
endprocedure

&AtClient
procedure ReadIDEAFile(ColorSchemeFilePath)
	
	TempDir = "";
	if StrEndsWith(Lower(ColorSchemeFilePath), "jar") then
		Zip = new ZipFileReader(ColorSchemeFilePath);
		Item = undefined;
		for each ZipItem in Zip.Items do
			if ZipItem.Path = "colors\" and ZipItem.Name <> "" then             
				Item = ZipItem;
				break;
			endif;	
		enddo;
		if Item = undefined then
			MessageToUser("Это не архив цветовой схемы нужного формата", "LocalSchemes");
			return;
		endif;
		TempDir = GetTempFileName();
		Zip.Extract(Item, TempDir, ZIPRestoreFilePathsMode.DontRestore);
		Zip.Close();
		XMLFilePath = TempDir + "\" + Item.Name;
	else
		XMLFilePath = ColorSchemeFilePath;                          
	endif;
	
	TextReader = new TextReader(XMLFilePath);
	StringXML = TextReader.Read();                                               
	TextReader.Close();
	StringXML = StrReplace(StringXML, """$$$""", "'$$$'");
	
	ColorScheme = ReadSchemeXML(StringXML);
	if ColorScheme = undefined then
		return;
	endif;
	
	if TempDir <> "" then
		BeginDeletingFiles(, TempDir);
	endif;
	
	ClearColors();
	
	Colors = ColorScheme.colors;
	if XDTOHasProperty(Colors, "option") and TypeOf(Colors.option) = Type("XDTOList") then
		for each Color in Colors.option do
			SetColorFromSource("NameIDEA", Color.name, Color.value);
		enddo;
	endif;
	
	Attrs = ColorScheme.attributes;
	if XDTOHasProperty(Attrs, "option") and TypeOf(Attrs.option) = Type("XDTOList") then
		for each Attribute in Attrs.option do
			if not XDTOHasProperty(Attribute, "value") then
				continue;
			endif;
			if not XDTOHasProperty(Attribute.value, "option") then
				continue;
			endif;
			Option = Attribute.value.option;
			if TypeOf(Option) = Type("XDTOList") then
				for each Field in Option do
					if XDTOHasProperty(Field, "value") then
						SetColorFromSource("NameIDEA", Attribute.name + "." + Field.name, Field.value);
					endif;
				enddo;
			else
				SetColorFromSource("NameIDEA", Attribute.name + "." + Option.name, Option.value);
			endif;
		enddo;
	endif;
	
	SetDefaultColors("Des", Des_Identifiers);
	SetDefaultColors("EDT", EDT_Foreground);
	RefreshHTML("Des");
	RefreshHTML("EDT");
		
endprocedure

&AtClient
function ReadSchemeXML(val StringXML)
	
	try
		XMLReader = new XMLReader;
		XMLReader.SetString(StringXML);
		return XDTOFactory.ReadXML(XMLReader);
	except
		MessageToUser(ErrorInfo().Cause.Description);
		return undefined;
	endtry;

endfunction

&AtClient
procedure ClearColors()
	
	EmptyColor = new Color;
	for each Color in Des_ColorsTable do
		ThisObject["Des_" + Color.Name1C] = EmptyColor;
		Items["Des_" + Color.Name1C].TitleTextColor = WebColors.Red;
	enddo;
	for each Color in EDT_ColorsTable do
		ThisObject["EDT_" + Color.Name1C] = EmptyColor;
		Items["EDT_" + Color.Name1C].TitleTextColor = WebColors.Red;
	enddo;

endprocedure

// Если для переданного цвета схемы есть соответствие цвета 1С,
// записывает его в цвет на форме 
// 
// Parameters:
// 	ColumnName - String - Имя колонки соответствующего редактора
// 	ColumnValue - String - Название цвета редактора
// 	ColorValue - Arbitrary - Значение цвета
&AtClient
procedure SetColorFromSource(ColumnName, ColumnValue, ColorValue)
	
	FoundRows = Des_ColorsTable.FindRows(new Structure(ColumnName, ColumnValue));
	for each Row in FoundRows do
		AttrName = "Des_" + Row.Name1C;
		SetColor(AttrName, ColorValue);
	enddo;
	
	FoundRows = EDT_ColorsTable.FindRows(new Structure(ColumnName, ColumnValue));
	for each Row in FoundRows do
		AttrName = "EDT_" + Row.Name1C;
		SetColor(AttrName, ColorValue);
	enddo;
	
endprocedure

&AtClient
procedure SetColor(AttrName, ColorValue)
	
	Color = HEXtoRGB(ColorValue);
	if Color = undefined then
		return;
	endif;
	ThisObject[AttrName] = Color;
	Items[AttrName].TitleTextColor = WebColors.Black;

endprocedure

&AtClient
procedure SetDefaultColors(val IDE, CommonForeground)
	
	IDE = IDE + ?(StrEndsWith(IDE, "_"), "", "_");
	EmptyColor = new Color;
	Offset = 20;
	
	Foreground = ?(ThisObject[IDE + "Others"] = EmptyColor, CommonForeground, ThisObject[IDE + "Others"]);
	R = Foreground.R + ?(Foreground.R > 128, -1, 1) * Offset;
	G = Foreground.G + ?(Foreground.G > 128, -1, 1) * Offset;
	B = Foreground.B + ?(Foreground.B > 128, -1, 1) * Offset;
	DefaultForeground = new Color(R, G, B);
	
	Background = ThisObject[IDE + "Background"];
	R = Background.R + ?(Background.R > 128, -1, 1) * Offset;
	G = Background.G + ?(Background.G > 128, -1, 1) * Offset;
	B = Background.B + ?(Background.B > 128, -1, 1) * Offset;
	DefaultBackground = new Color(R, G, B);
	
	for each Color in ThisObject[IDE + "ColorsTable"] do
		if ThisObject[IDE + Color.Name1C] = EmptyColor then
			if BackgroundColors.FindByValue(Color.Name1C) = undefined then
				ThisObject[IDE + Color.Name1C] = DefaultForeground;
			else
				ThisObject[IDE + Color.Name1C] = DefaultBackground;
			endif;
		endif
	enddo;

endprocedure

&AtClient
procedure RefreshHTML(val IDE)
	
	IDE = IDE + ?(StrEndsWith(IDE, "_"), "", "_");
	HTML = ThisObject[IDE + "Template"];
	for each Line in ThisObject[IDE + "ColorsTable"] do
		if Line.DefaultColor = "" then
			continue;
		endif;
		Color = ThisObject[IDE + Line.Name1C];
		StrColor = StrTemplate("rgb(%1,%2,%3)", Color.R, Color.G, Color.B);
		HTML = StrReplace(HTML, ": " + Line.DefaultColor, ": " + StrColor);
	enddo;
	ThisObject[IDE + "HTML"] = HTML;
	
endprocedure

// Проверяет, есть ли свойство у объекта XDTO
// 
// Parameters:
// 	Obj - XDTODataObject - Объект для проверки
// 	Name - String - Имя свойства
// Returns:
// 	Boolean - Истина, если проверяемое свойство есть
&AtClient
function XDTOHasProperty(Obj, Name)
	
	return Obj.Properties().Get(Name) <> undefined
	
endfunction

// В списке значений записывает представление переданному значению
// Если такого значения в списке нет, оно добавляется
// 
// Parameters:
// 	List - ValueList - Исходный список значений
// 	Value - Arbitrary - Значение для поиска
// 	Presentation - String - Устанавливаемое представление
&AtClientAtServerNoContext
procedure SetPresentationToListValue(List, Value, Presentation)

	CurrentItem = List.FindByValue(Value);
	if CurrentItem = undefined then
		List.Add(Value, Presentation);
	else
		CurrentItem.Presentation = Presentation;
	endif;

endprocedure

// Выводит сообщение пользователю
// 
// Parameters:
// 	Text - String - Выводимый текст
// 	Field - String - Имя реквизита, к которому относится сообщение
&AtClientAtServerNoContext
procedure MessageToUser(Text, Field = "")
	
	UserMessage = new UserMessage;
	UserMessage.Field = Field;
	UserMessage.Text = Text;
	UserMessage.Message();
	
endprocedure

// Проверяет, начинается ли строка с указанной подстроки
// 
// Parameters:
// 	SourceString - String - Основная строка
// 	Substring - String - Проверяемая подстрока
// Returns:
// 	Boolean - Истина, если строка начинается с указанной подстроки
&AtClient
function StringStartsWith(SourceString, Substring)
	
    StrLen = StrLen(Substring);
    return Left(SourceString, StrLen) = Substring;
	
endfunction

#Region Converting

// Переводи строку JSON в значение
// 
// Parameters:
// 	String - String - Строка JSON
// 	ReadToMap - Boolean - Создавать Соответствие
// Returns:
// 	Arbitrary - Преобразованное значение
&AtClientAtServerNoContext
function FromJSON(String, ReadToMap = false)
	
	JSONReader = new JSONReader;
	JSONReader.SetString(String);
	Result = ReadJSON(JSONReader, ReadToMap);
	JSONReader.Close();
	return Result;
	
endfunction

// Сериализует переданный объект в строку JSON
// 
// Parameters:
// 	Object - Arbitrary - Сериализуемый объект
// Returns:
// 	String - Строка JSON
&AtClientAtServerNoContext
function ToJSON(Object)
	
	JSONWriter = new JSONWriter;
	JSONWriter.SetString();
	WriteJSON(JSONWriter, Object);
	return JSONWriter.Close();
	
endfunction

// Переводит цвет во внутреннее десятичное представление
// 
// Parameters:
// 	RGB - Color - Цвет для преобразования
// Returns:
// 	String - Закодированный цвет
&AtClientAtServerNoContext
function RGBtoDEC(val RGB)
	
	XDTO = Eval("XDTOSerializer");
	return
	"{""#"",9cd510c7-abfc-11d4-9434-004095e12fc7,2,
	|{3,0,
	|{" + XDTO.XMLString(RGB.R + RGB.G * 256 + RGB.B * 256 * 256) + "}
	|}
	|}";
	
endfunction

// Переводит цвет из десятичного формата в RGB
// 
// Parameters:
// 	Value - String - Десятичное представление цвета
// Returns:
// 	Color - Цвет RGB
&AtClientAtServerNoContext
function DECtoRGB(val Value)
	
	Value = Number(Value);
	R = Value%256;
	G = (Int(Value/256))%256;
	B = (Int(Value/(256 * 256)))%256;
	return new Color(R, G, B);
	
endfunction

// Возвращает 16-ричное представление RGB цвета 
// 
// Parameters:
// 	RGB - Color - Цвет для преобразования
// Returns:
// 	String - 16-ричный цвет
&AtClientAtServerNoContext
function RGBtoHEX(val RGB)
	
	XDTO = Eval("XDTOSerializer");
	return XDTO.XMLString(RGB);
	
endfunction

// Получает цвет RGB по 16-ричному представлению
// 
// Parameters:
// 	HEX - String - Цвет в 16-ричном виде
// Returns:
// 	Color - RGB цвет
&AtClientAtServerNoContext
function HEXtoRGB(val HEX)
	
	HEX = TrimAll(HEX);
	HEX = StrReplace(HEX, "#", "");
	
	if StrLen(HEX) > 6 then
		return undefined;
	endif;  	
	
	HEX = Left("000000", 6 - StrLen(HEX)) + HEX;
	HEX = Left(HEX, 6);
	HEX = "#" + HEX;
	XDTO = Eval("XDTOSerializer");
	return XDTO.XMLValue(Type("Color"), HEX);
	
endfunction

#EndRegion

#EndRegion

#endif