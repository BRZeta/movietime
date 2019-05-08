echo off
title Scratch Org Initialization

now=$(date +"%r")

echo -e "The setup process takes 20-30 minutes to complete.\n"

 Name of permission set that will be assigned
PERMSET_NAME=System_Administrator

:: Prompts user to enter a name for the scratch org
while [ ! -n "$ORG_NAME"  ] 
do
	echo "Enter a name for your scratch org:"
	read ORG_NAME
done

:: Command to create scratch org, makes it default and lives for 30 days
echo -e "Creating Scratch Org\n"
sfdx force:org:create -a ${ORG_NAME} -d 30 -s -f config/project-scratch-def.json --json

if [ "$?" = "1" ] 
then
	echo "Unable to create scratch org."
	exit
fi
echo -e "Scratch org ${ORG_NAME} created successfully\n"

:: Command to create user to allow some dependent metadata to be deployed
echo -e "Creating User\n"
sfdx force:user:create --setalias gem --definitionfile config/user-def.json

if [ "$?" = "1" ] 
then
	echo "Unable to create user."
	exit
fi

:: Command to Open Scratch org for monitoring
echo -e "Opening Scratch Org\n"
sfdx force:org:open -u ${ORG_NAME}

:: Command to push source to scratch org
echo -e "Pushing the source code, the process will take about 20 minutes. You can monitor the progress in Setup under Deployment Status"
echo -e "Deployment Start TIme: $now\n"
sfdx force:source:push -u ${ORG_NAME}

if [ "$?" = "1" ]
then 
	echo "Unable to Push Source Code"
	exit 
fi
echo -e "Source Code deployed successfully"
echo -e "Deployment End TIme: $now\n"

:: Command to import custom settings
echo -e "Importing Custom Settings\n"
sfdx force:data:tree:import -f data/Aura_Editability_Control__c.json,data/BQ_SFDC_Mapping__c.json,data/Campaign_Spend_Type_Auto_Default__c.json,data/ChargecodeCostSetup__c.json,data/Country_Item_Inherited_Fields__c.json,data/GEM_Objects_Sharing_Access_Level__c.json,data/GSuite_Profile_Mapping__c.json,data/IPLICR_Default_Approvers__c.json,data/IPLICR_Profile_Mapping__c.json,data/Item_Draft_Required_Fields__c.json,data/ItemSegmentEntryLowLevelMap__c.json,data/Item_Draft_Approver_Profile_List__c.json,data/My_Store_List_View_Display_Fields__c.json,data/National_Campaign_Inherited_Fields__c.json,data/Product2_Inherited_Fields__c.json,data/Product2_Override_Fields__c.json,data/Qualtrics_Language_Mapping__c.json,data/Qualtrics_Survey_Fields__c.json,data/Skip_Validation_Rule__c.json,data/CurrencySymbols1__c.json,data/CurrencySymbols2__c.json,data/CurrencyType.json

if [ "$?" = "1" ]
then 
	echo "Unable to import Custom Settings"
	exit 
fi
echo -e "Custom Settings imported successfully\n"

:: Command to import GEM Accounts and Contacts
echo -e "Importing GEM Accounts and Contacts\n"
sfdx force:data:tree:import -p data/Account-Contact-plan.json

if [ "$?" = "1" ]
then 
	echo "Unable to import Accounts and Contacts\n"
	exit 
fi
echo -e "Account and Contacts imported successfully\n"

:: Command to Assign System Admin Permission Set
::echo -e "Assigning ${PERMSET_NAME} Permission Set\n"
::sfdx force:user:permset:assign -n ${PERMSET_NAME} -u ${ORG_NAME} --json

::if [ "$?" = "1" ]
::then
::	echo "Unable to assign permission set"
::	exit 
::fi	
::echo -e "Permission set assigned successfully\n"

echo "Setup Completed Successfully."