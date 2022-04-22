#Created by: Guilherme Muniz (linkedin.com/in/guilhermemunizr)
##NAME: AZURE-EXPORT_VM_SNAPSHOT-TO-STORAGE_ACCOUNT_CONTAINER_BLOB
###OBJETIVE: Export Azure VM Snapshot to Storage Account/Container.
                #Validated for Storage Account/Container on the same Subscription, different Subscriptions on the same Tenant and different subscriptions on different Tenants. 

#PREREQUISITES
#1 - INSTALL AZURE CLI
    #https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli-windows?tabs=azure-cli
#2 - UPDATE AZURE CLI
    # On CMD RUN: az upgrade

#SOURCE
    $subscriptionid = "<subscriptionid>" #Declare the ID of the subscription where the Snapshot is.
    $resourcegroupname = '<resourcegroupname>' #Declare the name of the ID where the Snaposhot is.
    $snapshotname = '<snapshotname>' #Declare the snapshot name (no extension).
    $sasExpiryDuration = "3600" #Snapshot access duration time (in seconds). 3600=1 hour/86400=1 day.

#TARGET
    $storageaccountname = "<storageaccountname>" #Declare the Storage Account name.
    $storagecontainername = "<storagecontainername>" #Declare the name of the Container.
    $storageaccountkey = '<storageaccountkey>' #Must end with '=='
    $destinationVHDFileName = "destinationVHDFileName.vhd" #The .vhd file name must be different from the snapshot name.

#RUN
#Selects the subscription based on the ID of the $subscriptionid variable.    
    Select-AzSubscription -Subscription $subscriptionid
#1.Requests read access right to the declared Snapshot for the time defined in $sasExpiryDuration. 2.Shows the Snapshot access URL.
    $sas = Grant-AzSnapshotAccess -ResourceGroupName $resourcegroupname -SnapshotName $snapshotname -DurationInSecond $sasexpiryduration -Access "Read" #
    $sas.AccessSAS
#Declares the "Target Context" based on the Storage Account variables.
    $destinationContext = New-AzStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $storageaccountkey
#Perform Snapshot copy job to Storage Account/Container as blob type file.
    $snapshotcopy = Start-AzStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer $storagecontainername -DestContext $destinationContext -DestBlob $destinationVHDFileName
#Shows the % status of the 'verbose' job.    
    $snapshotcopy | Get-AzStorageBlobCopyState -WaitForComplete
