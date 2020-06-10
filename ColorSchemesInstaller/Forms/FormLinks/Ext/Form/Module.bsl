
&AtClient
procedure LinkClick(Item)
	
	BeginRunningApplication(new NotifyDescription("LinkClickEnd", ThisObject), Item.Title);
	
endprocedure

//@skip-warning
&AtClient
procedure LinkClickEnd(ReturnCode, AdditionalParameters) export
	
endprocedure