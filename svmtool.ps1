<#
.SYNOPSIS
	The svmdr script allows to manage DR relationship at SVM level
	It also help to Backup & Restore SVM configuration
.DESCRIPTION
	This script deploy tools to:
	creates and manages Disaster Recovery SVM for ONTAP cluster
	Backup & Restore full configuration settings of an SVM
.PARAMETER Vserver
    Vserver Name of the source Vserver
.PARAMETER Instance
    Instance Name which will associate two cluster for a DR scenario
    An instance could manage one or several SVM DR relationships inside the corresponding cluster
.PARAMETER RootAggr
    Allows to set a default aggregate for SVM root volume creation
    Used only with ConfigureDR or CloneDR options
.PARAMETER DataAggr
    Allows to set a default aggregate for all SVM data volume creation
    Used only with ConfigureDR, UpdateDR, UpdateReverse, CloneDR options
.PARAMETER MirrorSchedule
    Allows to set a SnapMirror automatic update schedule for Source to DR relationship 
.PARAMETER MirrorScheduleReverse
    Optional argument
    Allow to set a SnapMirror automatic update schedule for DR to Source relationship 
.PARAMETER ListInstance
	Display all Instance available and configured
.PARAMETER ImportInstance
	Import previous generation SVMDR script's instances
.PARAMETER RemoveInstance
    Allow to remove a previously configured instance
    -RemoveInstance <instance name>
.PARAMETER Setup
    Used with Instance to create a new instance
    -Instance <instance name> -Setup
.PARAMETER PrimaryCluster
    Use for silent setup
.PARAMETER SecondaryCluster
    Use for silent setup
.PARAMETER QuotaDR
    Use for silent setup
    Enables QuotaDR for this setup
.PARAMETER Help
    Display help message
.PARAMETER ResetPassword
    Allows to reset all passwords stored for all instances
.PARAMETER HTTP
    Optional argument
    Allow to connect controller with HTTP instead of HTTPS
.PARAMETER ConfigureDR
    Allow to Create (or update) a SVM DR relationship
    -Instance <instance name> -Vserver <vserver source name> -ConfigureDR [-SelectVolume]
.PARAMETER ShowDR
    Allow to display all informations for a particular SVM DR relationship
    -Instance <instance name> -Vserver <vserver source name> -ShowDR [-Lag] [-schedule] [-MSID]
    Optional parameters:
        Lag      : display lag beetween last transfert
		Schedule : display automatic schedule set on SnapMirror relationship
		MSID     : display volume MSID
.PARAMETER DeleteDR
    Allow to delete a SVM DR relationship, by deleting all data and object associated to the DR SVM
    -Instance <instance name> -Vserver <vserver source name> -DeleteDR
.PARAMETER DeleteSource
    During Migrate procedure, you could choose not to delete source SVM
    In this case, source SVM is only stopped
    Once everything has been test and validate on destination, you could safely delete the source SVM,
    by running DeleteSource step
.PARAMETER RemoveDRconf
    Delete configuration files for a particular SVM DR relationship
    -Instance <instance name> -Vserver <vserver source name> -RemoveDRconf
.PARAMETER UpdateDR
    Allow to update data and metadata for a particular SVM DR relationship
    -Instance <instance name> -Vserver <vserver source name> -UpdateDR
.PARAMETER Backup
    Backup Cluster/SVM configuration into JSON files
    Without specifying any Vserver, will backup all SVM availables
	-Backup <Cluster Name> [-Vserver <SVM name>] [-RecreateConf]
	-RecreateConf : Force recreate Backup configuration directory for selected Cluster
.PARAMETER Restore
	Restore Cluster/SVM configuration from JSON files
	Without specifying any Vserver, will list available SVM and propose to choose one to Restore
	-Restore <Cluster Name> [-Vserver <SVM name>] [-SelectBackupDate] [-Destination]
	-Vserver : Choose one SVM to restore. By Default restore all SVM available in Backup folder
	-SelectBackupDate : Ask script to display all dates availables and prompt user to choose a date to restore. 
						By default select last data available in backup folder
	-Destination : Destination Cluster where to restore selected SVM.
	               If not specified, script will ask for
.PARAMETER Migrate
    Allow to migrate a source SVM to destination SVM
    ConfigureDR and UpdateDR should have already been successful
	You could choose to cleanly delete source SVM
	Destination SVM is started with source identity (IP address and CIFS server identity)
    -Instance <instance name> -Vserver <vserver source name> -Migrate [-ForceUpdateSnapPolicy]
.PARAMETER CreateQuotaDR
    Allow to recreate all quota rules on the DR SVM
	-Instance <instance name> -Vserver <vserver source name> -CreateQuotaDR
	PS: SnapMirror relationship must be broken
.PARAMETER ReCreateQuota
    Allow to recreate all quota rules on the source SVM
    -Instance <instance name> -Vserver <vserver source name> -ReCreateQuota
.PARAMETER CorrectQuotaError
    Optional argument
    Allow to Correct Source Quota Error before to save replicate the Quota rules configuration in SVMTOOL_DB
	Used with ConfigureDR, UpdateDR and UpdateReverse
.PARAMETER IgnoreQtreeExportPolicy
    Optional argument
    Allow to not check Qtree Export Policy during an UpdateDR
    This option greatly reduces cutover window.
    This can only be used during the last UpdateDR, when activity has been shutdown on source and before the ActivateDR.
    Obviously, a previous UpdateDR should be run without this argument in order to sync all Qtree Export Policy.
	This penultimate UpdateDR will be launched (normaly without this argument) right after freezing all creation/modification/deletion of qtree, 
	but by keeping an activity on source platform.
.PARAMETER IgnoreQuotaOff
    Optional argument
    Allow to ignore a volume for which quota are currently set to off
    Used with ConfigureDR, UpdateDR and UpdateReverse
.PARAMETER LastSnapshot
    Deprecated
.PARAMETER UpdateReverse
    Allow to update data and metadata during a DR test or crash un reverse order, from DR to source
    -Instance <instance name> -Vserver <vserver source name> -UpdateReverse
.PARAMETER CleanReverse
    Remove all broken Reverse SnapMirror relationship (after DR test or crash)
    -Instance <instance name> -Vserver <vserver source name> -CleanReverse
.PARAMETER Resync
    Force a manual update of all data only for a particular DR relationship 
    -Instance <instance name> -Vserver <vserver source name> -Resync
.PARAMETER ActivateDR
    Allow to activate a DR SVM for test or after a real crash on the source
	-Instance <instance name> -Vserver <vserver source name> -ActivateDR [-ForceActivate] [-ForceUpdateSnapPolicy]
.PARAMETER CloneDR
	Clone a Vserver on destination Cluster
	A new temporary Vserver will be created on destination Cluster (named <destination-vserver>_clone)
	All destination volumes will be cloned as RW volumes and hosted into this new temporary Vserver
	This allows testing the DR without interrupting SnapMirror relationship between Source Vserver and Destination Vserver
	-Instance <instance name> -Vserver <vserver source name> -CloneDR [-DataAggr <default data aggregate name>] [-DefaultPass] [-RootAggr <default svm rootvol aggregate name>]
.PARAMETER SplitCloneDR
	Split a Cloned Vserver
.PARAMETER DeleteCloneDR
	Delete a Cloned Vserver
	-Instance <instance name> -Vserver <vserver source name> -DeleteCloneDR [-CloneName <Vserver Clone DR name>]
	If [-CloneName] is not specified, script will search for all Clones associated with DR Vserver for this instance
	Only delete Cloned Vserver where all Flexclone are not splitted
.PARAMETER CloneName
	Name of the Cloned Vserver to work with
	Use with [-DeleteCloneDR]
.PARAMETER DefaultPass
	Force a Default Password for all users inside an SVM DR or Clone SVM
.PARAMETER ForceActivate
    Mandatory argument in case of disaster in Source site
	Used only with ActivateDR when source site is unjoinable
.PARAMETER ForceRestart
	Optional argument used to force restart of a stopped Vserver
	Used with ReActivate option
.PARAMETER ForceDeleteQuota
    Optional argument
    Allow to forcibly delete a quota rules in error
    Used with ConfigureDR, UpdateDR and UpdateReverse
.PARAMETER ForceRecreate
    Optional argument used only in double DR scenario or during Source creation after disaster
    Allow to forcibly recreate a SnapMirror relationship
	Used with ReaActivate, Resync and ResyncReverse
.PARAMETER ForceUpdateSnapPolicy
	Optional argument
	Allow to forcibly update SnapShot Policy on destination volume, based on source Snapshot Policy
	Warning: If Source & Destination volume have different number of snapshot (XDP relationship)
			 This could cause the deletion of snapshot on destination
.PARAMETER AlwaysChooseDataAggr
    Optional argument used to always ask to choose a Data Aggregate to store each Data volume
    Used with ConfigureDR only
.PARAMETER SelectVolume
    Optional argument used to choose for each source volume if it needs to be replicated/cloned on SVM DR or not
    Used with ConfigureDR and CloneDR only
.PARAMETER ResyncReverse
    Force a manual update of all data only for a particular DR relationship in reverse order, DR SVM to Source SVM 
    -Instance <instance name> -Vserver <vserver source name> -ResyncReverse
.PARAMETER ReActivate
    Allows to ReActivate a source SVM after a DR-test or RealLife Crash.  
    This will ReverseActivateDR (Destination->Source) + Resync (Source->Destination), 
    thus recovering the relationship to the original state (Source->Destination)
    -Instance <instance name> -Vserver <vserver source name> -ReActivate [-ForceUpdateSnapPolicy]
.PARAMETER Version
    Display version of the script
.PARAMETER DRfromDR
    Optional argument used only in double DR scenario
    Allow to create the second DR relationship for a particular instance and SVM
    Used only with ConfigureDR
.PARAMETER XDPPolicy
    Optional argument to specify a particular SnapMirror policy to use when creates XDP relationship
    By defaut, it use MirrorAllSnapshots policy
	The specified Policy must already exists in ONTAP and be correctly configured
.PARAMETER DebugLevel
	Deprecated - use the LogLevelConsole & LogLevelLogFile parameters and the level "Debug"
.PARAMETER NoLog
    Deprecated - use the LogLevelLogFile parameter and the level "Off"
.PARAMETER Silent
    Deprecated - use the LogLevelConsole parameter and the level "Off"
.PARAMETER LogLevelConsole
    Optional argument to set the level of logging for the console
    Values are Debug,Info,Warn,Error,Fatal,Off
.PARAMETER LogLevelLogFile
    Optional argument to set the level of logging for logging to file
    Values are Debug,Info,Warn,Error,Fatal,Off
.PARAMETER DefaultLocalUserCredentials
    Optional argument to pass the credentials for local user create/update
    In NonInteractive Mode, we cannot prompt for user password.  If you want users to be created, the password from these credentials is used.
.PARAMETER ActiveDirectoryCredentials
    Optional argument to pass the credentials for joining AD in NonInteractive Mode during configureDR
.PARAMETER TemporarySecondaryCifsIp
    For cifs, sometimes a secondary lif is needed to join in Active Directory (duplicate ip conflict)
    This ip address will be used to create that temporary lif
    Must be used together with SecondaryCifsLifMaster
.PARAMETER SecondaryCifsLifMaster
    For cifs, sometimes a secondary lif is needed to join in Active Directory (duplicate ip conflict)
    This lif will be used as a template to create a new temporary lif to complete this AD join
    Must be used together with TemporarySecondaryCifsIp
.PARAMETER NonInteractive
    Runs the script in Non Interactive Mode.  
    No confirmations and resource selection is automated
    If no smart resource selection is possible, the RootAggr and DataAggr parameters are used as a fallback
.PARAMETER WfaIntegration
    Will convert all logging to WFA Logging
    Will use WFA Cluster connection, using WFA storage credentials
    Will automatically run in NonInteractive Mode
.PARAMETER RW
	Only in Restore mode, this option will allow to create RW volume instead of default DP volume
	This cas be used when you want to restore/clone an SVM conf, but don't need to or can't restore data back through SnapMirror
.INPUTS
    None. You cannot pipe objects to this script
.OUTPUTS
    Only display result of operations
.LINK
    https://github.com/oliviermasson/svmtool
.EXAMPLE
    svmtool.ps1 -Instance test -Setup

    Create a new instance named test
.EXAMPLE
    svmtool.ps1 -Instance test -Vserver svm_source -ConfigureDR

    Configure a SVM DR relationship for SVM svm_source in the instance test
    And create all necessary DR objects
.EXAMPLE
    svmtool.ps1 -Instance test -Vserver svm_source -ConfigureDR -AlwaysChooseDataAggr -SelectVolume

    Configure a SVM DR relationship for SVM svm_source in the instance test
    Request user to select which volume will be replicated and which not
    Ask for each volume on which destination aggregate it will be provisionned
.EXAMPLE
   svmtool.ps1 -Instance test -Vserver svm_source -UpdateDR
   
   Set and Update all data and metadata for the DR SVM associated with source SVM svm_source
.EXAMPLE
    svmtool.ps1 -Instance test -Vserver svm_source -ActivateDR
    
	Activate the DR SVM associated with source SVM svm_source
	Snapshot Policy on destination volume will not beeing updated
    Access will be allowed on DR SVM
.EXAMPLE
    svmtool.ps1 -Instance test -Vserver svm_source -ResyncReverse
    
    Following an ActivateDR, create a reverse SnapMirror relationship from DR to source and erase data only on source SVM
.EXAMPLE
    svmtool.ps1 -Instance test -Vserver svm_source -UpdateReverse

    Following a ResyncReverse, push all metadata modifications achieved on DR SVM to source SVM
.EXAMPLE
    svmtool.ps1 -Instance test -Vserver svm_source -ReActivate

	Following an ActivateDR, restart production on source SVM
.EXAMPLE
	svmtools.ps1 -Instance test -Vserver source_svm -ShowDR [-Schedule] [-Lag] [-MSID]

	Display status and details of source SVM object and destination SVM object, as well as all SnapMirror relatiohships
	Use color to display destination volume different from source
	With option -Schedule, it also display SnapMirror schedule that is set
	With option -Lag, it also display SnapMirror Lag
	With option -MSID, it also display volume MSID
.EXAMPLE
	svmtool.ps1 -Instance test -Vserver svm_source -Migrate -ForceUpdateSnapPolicy

	Following successful ConfigureDR and UpdateDR, Migrate an SVM to destination cluster
	During this step, you will be prompt to delete or not source SVM and all its objects
	If not deleted, source SVM is stopped
	Once Migration is done, destination SVM gain source identity
	Temporary IP address are replaced by source IP address and CIFS server identity is changed with source name
.EXAMPLE
	svmtool.ps1 -Instance test -Vserver svm_source -DeleteSource
	
	When Migrate is performed without deleting source SVM, you can choose (when ready)
	to delete source SVM by using -DeleteSource option
	During this step, SVM name on destination Cluster will be renamed with source name
	And all objects of source SVM, and source SVM itself will be destroyed
.EXAMPLE
	svmtool.ps1 -Backup clusterA [-Vserver <svm name>]

	Backup all SVM on clusterA.
	If Backup&Restore Instance associated to clusterA does not exist, the script will create it.
	All SVM will be backed up in separate folder inside the directory chosen for this instance
	If you want to recreate the instance for clusterA, add -Recreateconf
	If you want to only Backup a particular SVM, add -Vserver <svm name>
.EXAMPLE
	svmtool.ps1 -Restore clusterA [-Vserver <svm name>] -Destination clusterB [-RW] [-SelectBackupDate] 

	Restore all SVM available from the Backup folder defined in the clusterA Backup&Restore instance to clusterB
	If you need to restore a particular SVM, just -add -Vserver <svm name>
	By default, the script will automaticaly restore from the most recent backup folder available for each SVM
	If you want to restore from a particular date, just add -SelectBackupDate, and the script will display all dates available
	for each SVM and prompt you to chose the date you want
	By default, the script restore all volume as Data-Protection type (DP) volume. 
	In order to allow you to restore data inside this volumes from a SnapMirror/SnapVault previous backup.
	If you don't have a SnapMirror/SnapVault backup or will restore data back with another method,
	or because you only need to recreate the "envelop" fo the SVM (to clone an environment by example), just add -RW to the command line
	In that case, all volumes will be restored as Read/Write (RW) volume.
.EXAMPLE
	svmtool.ps1 -Instance <instance name> -Vserver <vserver source name> -CloneDR [-DataAggr <default data aggregate name>] [-RootAggr] [-DefaultPass]

	Create a temporary Clone Vserver on destination cluster
	Clone all destinations volumes (DP) into this cloned vserver as Read/Write volume (RW)
	In order, to perform/test the DR without interrupting Snapmirror relationship during the timeframe of the DR test
	It could also be used to provision an cloned environment of production SVM on destination cluster for test/dev
	Once cloned environment successfully done, all volumes are Flexclone volumes attached to destinations volumes through lastest snapshot available
	If needed, this cloned environment and all its volumes could be split from destination vserver : see SplitCloneDR option
	With the optional arugment -SelectVolume, you could choose which volume will be cloned in the temporay Cloned SVM
.EXAMPLE
	svmtool.ps1 -Instance <instance name> -Vserver <vserver source name> -DeleteCloneDR -CloneName PSLAB_DR_clone.2

	Completely delete Vserver Clone named PSLAB_DR_clone.2 from secondary cluster
.NOTES
    Author  : Olivier Masson
    Author  : Mirko Van Colen
    Version : October 8th, 2018
    Version History : 
        - 0.0.3 : Initial version 
        - 0.0.4 : Bugfix, typos and added ParameterSets
		- 0.0.5 : Bugfixes, advancements and colorcoding
		- 0.0.6 : Change behaviour when SVM has no LIF, nor Data volume
		- 0.0.7 : Add ForceUpdateSnapPolicy to not update snapshot policy on destination volumes by default
				  Add EXAMPLE for ShowDR, DeleteSource, Migrate, ...
    - 0.0.8 : Add CloneDR option to create Cloned SVM from Destination Vserver
				      Add DeleteCloneDR option to remove a previously Cloned Vserver          
    - 0.0.9 : Added symlinks and noninteractive mode
              Bugfixes (cifs groups & users)
              Added default usercredentials for noninteractive mode
              Added smart resource selections (with regex and defaults) for noninteractive mode
              Minor typos
              Remove Restamp_msid option
				     Add ForceRestart optional parameter to forcibly restart a stopped Vserver during ReActivate step
    - 0.1.0 : Adding log4net logging and WFA logging integration, setup can now run in noninteractive mode
    - 0.1.1 : Bugfixes, added new cmdlet wrapper with official verbs
#>
[CmdletBinding(HelpURI="https://github.com/oliviermasson/svmtool",DefaultParameterSetName="ListInstance")]
Param (

    [Parameter(Mandatory = $true, ParameterSetName='Setup')]
    [switch]$Setup,

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
	  [string]$PrimaryCluster,

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
	  [string]$SecondaryCluster,

    [Parameter(Mandatory = $true, ParameterSetName='ConfigureDR')]
    [switch]$ConfigureDR,

    [Parameter(Mandatory = $true, ParameterSetName='UpdateDR')]
	  [switch]$UpdateDR,

    [Parameter(Mandatory = $true, ParameterSetName='ShowDR')]
	  [switch]$ShowDR,

    [Parameter(Mandatory = $true, ParameterSetName='ActivateDR')]
	  [switch]$ActivateDR,

	  [Parameter(Mandatory = $true, ParameterSetName='CloneDR')]
	  [switch]$CloneDR,

	  [Parameter(Mandatory = $true, ParameterSetName='SplitCloneDR')]
	  [switch]$SplitCloneDR,

	  [Parameter(Mandatory = $true, ParameterSetName='DeleteCloneDR')]
	  [switch]$DeleteCloneDR,

    [Parameter(Mandatory = $true, ParameterSetName='DeleteDR')]
	  [switch]$DeleteDR,

    [Parameter(Mandatory = $true, ParameterSetName='RemoveDRConf')]
    [switch]$RemoveDRConf,

    [Parameter(Mandatory = $true,ParameterSetName='ResyncReverse')]
	  [switch]$ResyncReverse,

    [Parameter(Mandatory = $true, ParameterSetName='UpdateReverse')]
	  [switch]$UpdateReverse,

    [Parameter(Mandatory = $true, ParameterSetName='ReActivate')]
	  [switch]$ReActivate,

    [Parameter(Mandatory = $true, ParameterSetName='CleanReverse')]
    [switch]$CleanReverse,

    [Parameter(Mandatory = $true, ParameterSetName='Resync')]
    [switch]$Resync,
    
    [Parameter(Mandatory = $true,ParameterSetName='Version')]
    [switch]$Version,

    [Parameter(Mandatory = $true, ParameterSetName='ListInstance')]
    [switch]$ListInstance,

    [Parameter(Mandatory = $true, ParameterSetName='ImportInstance')]
    [switch]$ImportInstance,

    [Parameter(Mandatory = $true, ParameterSetName='RemoveInstance')]
    [string]$RemoveInstance,

    [Parameter(Mandatory = $true, ParameterSetName='Backup')]
    [string]$Backup,

    [Parameter(Mandatory = $true, ParameterSetName='Restore')]
    [string]$Restore,

    [Parameter(Mandatory = $true, ParameterSetName='MirrorSchedule')]
    [string]$MirrorSchedule,

    [Parameter(Mandatory = $true, ParameterSetName='MirrorScheduleReverse')]
    [string]$MirrorScheduleReverse,

    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $true, ParameterSetName='DeleteSource')]
    [switch]$DeleteSource,

    [Parameter(Mandatory = $true, ParameterSetName='Migrate')]
    [switch]$Migrate,

    [Parameter(Mandatory = $true, ParameterSetName='CreateQuotaDR')]
    [switch]$CreateQuotaDR,

    [Parameter(Mandatory = $true, ParameterSetName='ReCreateQuota')]
    [switch]$ReCreateQuota,

    [Parameter(Mandatory = $true, ParameterSetName='Help')]
    [switch]$Help,

    [Parameter(Mandatory = $true, ParameterSetName='InternalTest')]
    [switch]$InternalTest,

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
    [Parameter(Mandatory = $true, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $true, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $true, ParameterSetName='ShowDR')]
    [Parameter(Mandatory = $true, ParameterSetName='ActivateDR')]
    [Parameter(Mandatory = $true, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $true, ParameterSetName='SplitCloneDR')]
    [Parameter(Mandatory = $true, ParameterSetName='DeleteCloneDR')]
    [Parameter(Mandatory = $true, ParameterSetName='DeleteDR')]
    [Parameter(Mandatory = $true, ParameterSetName='RemoveDRConf')]
    [Parameter(Mandatory = $true, ParameterSetName='MirrorSchedule')]
    [Parameter(Mandatory = $true, ParameterSetName='ResyncReverse')]
    [Parameter(Mandatory = $true, ParameterSetName='UpdateReverse')]
    [Parameter(Mandatory = $true, ParameterSetName='MirrorScheduleReverse')]
    [Parameter(Mandatory = $true, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $true, ParameterSetName='CleanReverse')]
    [Parameter(Mandatory = $true, ParameterSetName='Resync')]
    [Parameter(Mandatory = $false, ParameterSetName='Backup')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
    [Parameter(Mandatory = $true, ParameterSetName='DeleteSource')]
    [Parameter(Mandatory = $true, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $true, ParameterSetName='CreateQuotaDR')]
    [Parameter(Mandatory = $true, ParameterSetName='ReCreateQuota')]
    [Parameter(Mandatory = $true, ParameterSetName='InternalTest')]
    [string]$Vserver,

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
    [string]$VserverDr,

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
    [switch]$QuotaDR,

    [Parameter(Mandatory = $true, ParameterSetName='Setup')]
    [Parameter(Mandatory = $true, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $true, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $true, ParameterSetName='ShowDR')]
    [Parameter(Mandatory = $true, ParameterSetName='ActivateDR')]
    [Parameter(Mandatory = $true, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $true, ParameterSetName='SplitCloneDR')]
    [Parameter(Mandatory = $true, ParameterSetName='DeleteCloneDR')]
    [Parameter(Mandatory = $true, ParameterSetName='DeleteDR')]
    [Parameter(Mandatory = $false, ParameterSetName='RemoveDRConf')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorSchedule')]
    [Parameter(Mandatory = $true, ParameterSetName='ResyncReverse')]
    [Parameter(Mandatory = $true, ParameterSetName='UpdateReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorScheduleReverse')]
    [Parameter(Mandatory = $true, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $true, ParameterSetName='CleanReverse')]
    [Parameter(Mandatory = $true, ParameterSetName='Resync')]
    [Parameter(Mandatory = $true, ParameterSetName='DeleteSource')]
    [Parameter(Mandatory = $true, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='CreateQuotaDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ReCreateQuota')]
    [Parameter(Mandatory = $false, ParameterSetName='InternalTest')]
    [string]$Instance,

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
	  [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
	  [Parameter(Mandatory = $false, ParameterSetName='Restore')]
	  [string]$RootAggr="",
	  [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [switch]$AlwaysChooseDataAggr,
	  [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
	  [switch]$SelectVolume,
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [switch]$DRfromDR,
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
  	[string]$XDPPolicy="MirrorAllSnapshots",

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
  	[string]$DataAggr,

    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
  	[switch]$LastSnapshot,

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
  	[string]$AggrMatchRegex,    

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
  	[string]$NodeMatchRegex,    

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
  	[switch]$CorrectQuotaError,
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
  	[switch]$IgnoreQtreeExportPolicy,
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
   	[switch]$IgnoreQuotaOff,
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
    [switch]$ForceDeleteQuota,

    [Parameter(Mandatory = $false, ParameterSetName='ActivateDR')]
	  [switch]$ForceActivate,

    [Parameter(Mandatory = $false, ParameterSetName='ReActivate')]
    [switch]$ForceRestart,

    [Parameter(Mandatory = $false, ParameterSetName='ShowDR')]
    [switch]$MSID,
    [Parameter(Mandatory = $false, ParameterSetName='ShowDR')]
  	[switch]$Lag,
    [Parameter(Mandatory = $false, ParameterSetName='ShowDR')]
  	[switch]$Schedule,

    [Parameter(Mandatory = $false, ParameterSetName='ListInstance')]
  	[switch]$ResetPassword,

    [Parameter(Mandatory = $false, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $false, ParameterSetName='Resync')]
    [Parameter(Mandatory = $false, ParameterSetName='ResyncReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
	  [switch]$ForceRecreate,

  	[Parameter(Mandatory = $false, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $false, ParameterSetName='ActivateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [switch]$ForceUpdateSnapPolicy,

    [Parameter(Mandatory = $false, ParameterSetName='Backup')]
	  [switch]$Recreateconf,
	
  	[Parameter(Mandatory = $true, ParameterSetName='DeleteCloneDR')]
    [string]$CloneName="",

    [Parameter(Mandatory = $true, ParameterSetName='Restore')]
  	[string]$Destination="",
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
  	[switch]$SelectBackupDate,
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
  	[switch]$RW,

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ShowDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ActivateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteDR')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorSchedule')]
    [Parameter(Mandatory = $false, ParameterSetName='ResyncReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorScheduleReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $false, ParameterSetName='CleanReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='Resync')]
    [Parameter(Mandatory = $false, ParameterSetName='Backup')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteSource')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='CreateQuotaDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ReCreateQuota')]
    [Parameter(Mandatory = $false, ParameterSetName='InternalTest')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='SplitCloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteCloneDR')]
  	[switch]$HTTP,

  	[switch]$NoLog,
    [switch]$Silent,

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
    [Parameter(Mandatory = $false, ParameterSetName='ListInstance')]
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ShowDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ActivateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteDR')]
    [Parameter(Mandatory = $false, ParameterSetName='RemoveDRConf')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorSchedule')]
    [Parameter(Mandatory = $false, ParameterSetName='ResyncReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorScheduleReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $false, ParameterSetName='CleanReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='Resync')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteSource')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='CreateQuotaDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ReCreateQuota')]
    [Parameter(Mandatory = $false, ParameterSetName='InternalTest')]
    [Parameter(Mandatory = $false, ParameterSetName='Backup')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
    [Parameter(Mandatory = $false, ParameterSetName='ImportInstance')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='SplitCloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteCloneDR')]
    [ValidateSet("Debug","Info","Warn","Error","Fatal","Off")]
    [string]$LogLevelConsole="Info",

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
    [Parameter(Mandatory = $false, ParameterSetName='ListInstance')]
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ShowDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ActivateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteDR')]
    [Parameter(Mandatory = $false, ParameterSetName='RemoveDRConf')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorSchedule')]
    [Parameter(Mandatory = $false, ParameterSetName='ResyncReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorScheduleReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $false, ParameterSetName='CleanReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='Resync')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteSource')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='CreateQuotaDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ReCreateQuota')]
    [Parameter(Mandatory = $false, ParameterSetName='InternalTest')]
    [Parameter(Mandatory = $false, ParameterSetName='Backup')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
    [Parameter(Mandatory = $false, ParameterSetName='ImportInstance')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='SplitCloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteCloneDR')]
    [ValidateSet("Debug","Info","Warn","Error","Fatal","Off")]
    [string]$LogLevelLogFile="Info",

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ShowDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ActivateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteDR')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='SplitCloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteCloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='RemoveDRConf')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorSchedule')]
    [Parameter(Mandatory = $false, ParameterSetName='ResyncReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorScheduleReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $false, ParameterSetName='CleanReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='Resync')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteSource')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='CreateQuotaDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ReCreateQuota')]
    [Parameter(Mandatory = $false, ParameterSetName='InternalTest')]
    [Parameter(Mandatory = $false, ParameterSetName='Backup')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
	  [Int32]$Timeout = 60,

    [Parameter(Mandatory = $false, ParameterSetName='Setup')]
    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ActivateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteDR')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorSchedule')]
    [Parameter(Mandatory = $false, ParameterSetName='ResyncReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='MirrorScheduleReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='ReActivate')]
    [Parameter(Mandatory = $false, ParameterSetName='CleanReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='Resync')]
    [Parameter(Mandatory = $false, ParameterSetName='Backup')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
    [Parameter(Mandatory = $false, ParameterSetName='DeleteSource')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='CreateQuotaDR')]
    [Parameter(Mandatory = $false, ParameterSetName='ReCreateQuota')]
    [switch]$NonInteractive,

    [switch]$WfaIntegration,

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateDR')]
    [Parameter(Mandatory = $false, ParameterSetName='UpdateReverse')]
    [Parameter(Mandatory = $false, ParameterSetName='Migrate')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]
    [pscredential]$DefaultLocalUserCredentials=$null,

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]    
    [pscredential]$ActiveDirectoryCredentials=$null,

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]    
    [string]$TemporarySecondaryCifsIp=$null,

    [Parameter(Mandatory = $false, ParameterSetName='ConfigureDR')]
    [Parameter(Mandatory = $false, ParameterSetName='CloneDR')]
    [Parameter(Mandatory = $false, ParameterSetName='Restore')]    
    [string]$SecondaryCifsLifMaster=$null
)

#############################################################################################
# Minimum Netapp Supported TK
#############################################################################################
$Global:MIN_MAJOR = 4
$Global:MIN_MINOR = 3
$Global:MIN_BUILD = 0
$Global:MIN_REVISION = 0
#############################################################################################
$Global:RELEASE="0.1.1"
$Global:BASEDIR='C:\Scripts\SVMTOOL'
$Global:SVMTOOL_DB_DEFAULT = $Global:BASEDIR
$Global:CONFBASEDIR=$BASEDIR + '\etc\'
$Global:STOP_TIMEOUT=360
$Global:START_TIMEOUT=360
$Global:SINGLE_CLUSTER = $False
$DebugPreference="SilentlyContinue"
$VerbosePreference="SilentlyContinue"
$ErrorActionPreference="Continue"
if($WfaIntegration -or $UpdateDR -or $UpdateReverse){
    $NonInteractive=$true
}
$Global:NonInteractive=$NonInteractive
if($NonInteractive){
    $AlwaysChooseDataAggr=$true
}
$Global:LogLevelConsole=$LogLevelConsole
$Global:AlwaysChooseDataAggr=$AlwaysChooseDataAggr
$Global:WfaIntegration=$WfaIntegration
$Global:DefaultLocalUserCredentials=$DefaultLocalUserCredentials
$Global:ActiveDirectoryCredentials=$ActiveDirectoryCredentials
$Global:BACKUPALLSVM=$False
$Global:NumberOfLogicalProcessor = (Get-WmiObject Win32_Processor).NumberOfLogicalProcessors
if($Global:NumberOfLogicalProcessor -lt 4){
    $Global:NumberOfLogicalProcessor = 4
}
$Global:maxJobs=100
$Global:XDPPolicy=$XDPPolicy
$Global:RootAggr=$RootAggr
$Global:DataAggr=$DataAggr
$Global:DefaultPass=$DefaultPass
$Global:Schedule=$Schedule

if ( ( $Instance -eq $null ) -or ( $Instance -eq "" ) ) {
    if ($Backup.Length -eq 0 -and $Restore.Length -eq 0){
        $Global:CONFDIR=$Global:CONFBASEDIR + 'default\'
    }elseif($Backup.Length -gt 0){
        $Global:CONFDIR=$Global:CONFBASEDIR + $Backup + '\'
	}elseif($Restore.Length -gt 0){
        $Global:CONFDIR=$Global:CONFBASEDIR + $Restore + '\'
    }
} else  {
	$Global:CONFDIR=$Global:CONFBASEDIR + $Instance + '\'
}

$Global:CONFFILE=$Global:CONFDIR + 'svmtool.conf'

$Global:ROOTLOGDIR=($Global:BASEDIR + '\log\')

if($Backup -ne "") {
	$Global:ROOTLOGDIR=($Global:ROOTLOGDIR + $Backup + '\')
	if(-not (Test-Path $Global:ROOTLOGDIR)){
        New-Item -Path $Global:ROOTLOGDIR -ItemType "directory" -ErrorAction "silentlycontinue" | Out-Null
    }		
}

if($Restore -ne "") {
	$Global:ROOTLOGDIR=($Global:ROOTLOGDIR + $Restore + '\')
	if(-not (Test-Path $Global:ROOTLOGDIR)){
        New-Item -Path $Global:ROOTLOGDIR -ItemType "directory" -ErrorAction "silentlycontinue" | Out-Null
    }
}

if($Vserver -ne "" -and ($Backup -eq "" -and $Restore -eq "")) {
	$Global:LOGDIR=($Global:ROOTLOGDIR + $Vserver + '\')
} else {
	$Global:LOGDIR = $Global:ROOTLOGDIR
}

$LOGFILE=$LOGDIR + "svmtool.log"
$Global:CRED_CONFDIR=$BASEDIR  + "\cred\"
$Global:MOUNT_RETRY_COUNT = 100

#############################################################################################
# MAIN
#############################################################################################
$Path=$env:PSModulePath.split(";")
if($Path -notcontains $PSScriptRoot){
    $Path+=$PSScriptRoot
    $Path=[string]::Join(";",$Path)
    [System.Environment]::SetEnvironmentVariable('PSModulePath',$Path)
}
remove-module -Name svmtools -ErrorAction SilentlyContinue
$module=import-module "$PSScriptRoot\svmtools" -PassThru
if ( $module -eq $null ) {
        Write-Host "ERROR: Failed to load module SVMTOOLS" -ForegroundColor Red
        Write-Error "ERROR: Failed to load module SVMTOOLS"
        exit 1
}
if(!($env:PSModulePath -match "NetApp PowerShell Toolkit")){
    $env:PSModulePath=$($env:PSModulePath+";C:\Program Files (x86)\NetApp\NetApp PowerShell Toolkit\Modules")
}
if(-not $WfaIntegration){
    $module=import-module -Name DataONTAP -PassThru
    if ( $module -eq $null ) {
            Write-Error "ERROR: DataONTAP module not found" 
            clean_and_exit 1
    }
}else{
    $module=import-module "$PSScriptRoot\..\DataOntap" -PassThru
}
# initialize log4net, only needed once.
init_log4net

# appenders (logfile, eventviewer & console)
$masterLogFileAppender = create_rolling_log_appender -name "svmtool.log" -file $LOGFILE -threshold $LogLevelLogFile
$masterEventViewerAppender = create_eventviewer_appender -name "eventviewer" -applicationname "svmtool"
$consoleAppender = create_console_appender -name "console" -threshold $LogLevelConsole

# initialize logonly
add_appender -loggerinstance "logonly" $masterLogFileAppender
set_log_level -loggerinstance "logonly" -level "All"
$Global:MasterLog = get_logger -name "logonly" 

# initialize console
add_appender -loggerinstance "console" $masterLogFileAppender
add_appender -loggerinstance "console" $masterEventViewerAppender
add_appender -loggerinstance "console" $consoleAppender 
set_log_level -loggerinstance "console" -level "All"
$Global:ConsoleLog = get_logger -name "console"

check_ToolkitVersion 

if($LastSnapshot){Write-Warn "The switch -LastSnapshot is deprecated, Cdot always transfers last snapshot"}
if($Silent){
    Write-Warn "The switch -Silent is deprecated, please use parameter -LogLevelConsole"
    $LogLevelConsole = "Off"
}
if($NoLog){
    Write-Warn "The switch -NoLog is deprecated, please use parameter -LogLevelLogFile"
    $LogLevelLogFile = "Off"
}

if($DebugLevel){
    Write-Warn "The switch -DebugLevel is deprecated, please use parameters -LogLevelLogFile Debug or -LogLevelConsole Debug"
    $LogLevelLogFile = "Debug"
}

if ( ( check_init_setup_dir ) -eq $False ) {
        Write-LogError "ERROR: Failed to create new folder item: exit" 
        clean_and_exit 1
}

Write-LogOnly ""
Write-LogOnly "SVMTOOL START"
if ( $Help ) { Write-Help }
if ( $Version ) {
	$ModuleVersion=(Get-Module -Name svmtools).Version
	$ModuleVersion=$ModuleVersion.ToString()
	Write-Log "Script Version [$RELEASE]"
	Write-Log "Module Version [$ModuleVersion]"
	Clean_and_exit 0 
}
Write-LogDebug "BASEDIR           [$BASEDIR]"
Write-LogDebug "CONFDIR           [$CONFDIR]"
Write-LogDebug "LOGDIR            [$LOGDIR]"
Write-LogDebug "LOGFILE           [$LOGFILE]"
Write-LogDebug "CRED_CONFDIR      [$CRED_CONFDIR]"
Write-LogDebug "CONFFILE          [$CONFFILE]"
Write-LogDebug "VERSION           [$RELEASE]"
Write-LogDebug "Vserver           [$Vserver]"
Write-LogDebug "LogLevelConsole   [$LogLevelConsole]"
Write-LogDebug "LogLevelLogFile   [$LogLevelLogFile]"
Write-LogDebug "RW                [$RW]"

if ( $ListInstance ) {
	show_instance_list -ResetPassword:$ResetPassword
	clean_and_exit 0
}

if($ImportInstance){
	if(($ret=import_instance_svmdr) -eq $True){
		clean_and_exit 0
	}else{
		clean_and_exit 1	
	}
	
}

if ( $RemoveInstance ) {
	if ( ( remove_configuration_instance $RemoveInstance ) -eq $True ) {
		clean_and_exit 0
	} else {
		clean_and_exit 1
	}
}

if ( $Setup ) {
    if($Global:NonInteractive){
        if(-not $PrimaryCluster -or -not $SecondaryCluster){
            Write-LogError "ERROR : Setup in non interactive requires options PrimaryCluster, SecondaryCluster and optionally Vserver"
        }
    }
	create_config_file_cli -primaryCluster $PrimaryCluster -secondaryCluster $SecondaryCluster
	if ( ! $Vserver ) {
		clean_and_exit 1
	}
}

if ( $Backup ) {
    $Run_Mode="Backup"
    Write-Log "SVMTOOL Run Backup"
    if ((Test-Path $CONFFILE) -eq $True ) {
		Write-Log "use Config File [$CONFFILE]"s
		$read_conf = read_config_file $CONFFILE ;
		if ( $read_conf -eq $null ){
        		Write-LogError "ERROR: read configuration file $CONFFILE failed"
        		clean_and_exit 1 ;
        }
        $SVMTOOL_DB=$read_conf.Get_Item("SVMTOOL_DB")
        if($RecreateConf -eq $True){
            $ANS=Read-HostOptions -question "Configuration file already exist. Do you want to recreate it ?" -options "y/n" -default "y"
            if ( $ANS -ne 'y' ) { $RecreateConf=$False }
        }
    }
    if($RecreateConf -eq $True -or (Test-Path $CONFFILE) -eq $False){
		Write-Log "Create new Config File"
        $ANS='n'
        while ( $ANS -ne 'y' ) {
            if(-not $SVMTOOL_DB){
                $SVMTOOL_DB = $Global:SVMTOOL_DB_DEFAULT
            }
            $SVMTOOL_DB = Read-HostDefault -question  "Please enter Backup directory where configuration will be backup" -default $SVMTOOL_DB
            Write-Log "SVMTOOL Backup directory:  [$SVMTOOL_DB]"
            Write-Log ""
                $ANS = Read-HostOptions -question "Apply new configuration ?" -options "y/n/q" -default "y"
            if ( $ANS -eq 'q' ) { clean_and_exit 1 }
            write-Output "#" | Out-File -FilePath $CONFFILE  
			write-Output "SVMTOOL_DB=$SVMTOOL_DB\$Backup" | Out-File -FilePath $CONFFILE -Append 
			write-output "INSTANCE_MODE=BACKUP_RESTORE" | Out-File -FilePath $CONFFILE -Append
			write-output "BACKUP_CLUSTER=$Backup" | Out-File -FilePath $CONFFILE -Append  
        }
    }elseif($SVMTOOL_DB.Length -gt 0){
        Write-Log "Backup will be done inside [$SVMTOOL_DB]"
    }
    if($Vserver.length -eq 0){ 
        Write-LogDebug "No SVM selected. Will backup all SVM on Cluster [$Backup]"
        $BACKUPALLSVM=$True
    }else{
        Write-Log "Backup SVM [$Vserver] on Cluster [$Backup]"
    }

    $myCred=get_local_cDotcred ($Backup)
    $tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$Backup] with login [$tmp_str]"
	Write-LogDebug "connect_cluster -myController $Backup -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster -myController $Backup -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$Backup]" 
		clean_and_exit 1
    }
    if($BACKUPALLSVM -eq $True){
        $AllSVM=Get-NcVserver -Query @{VserverType="data";VserverSubtype="!sync_destination,!dp_destination"} -Controller $NcPrimaryCtrl -ErrorVariable ErrorVar 
        if ( $? -ne $True ) { $Return = $False ; throw "ERROR: Get-NcVserver failed [$ErrorVar]" }
        if($AllSVM){
            $SVMList=$AllSVM.Vserver
        }else{
            Write-Log "ERROR: No active SVM available on Cluster [$Backup]"
            clean_and_exit 1
        }
    }else{
        $SVMList=@($Vserver)   
    }
	$iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $RunspacePool_Backup=[runspacefactory]::CreateRunspacePool(1, $Global:NumberOfLogicalProcessor, $iss, $Host)
    $RunspacePool_Backup.Open()
    [System.Collections.ArrayList]$jobs = @()
    $SVMcount=$SVMList.Count
	$Jobs_Backup = @()
	$stopwatch=[system.diagnostics.stopwatch]::StartNew()
	$numJobBackup=0
	$BackupDate=Get-Date -UFormat "%Y%m%d%H%M%S"
    foreach($svm in $SVMList){
		$svm_status=Get-NcVserver -Vserver $svm -Controller $NcPrimaryCtrl -ErrorVariable ErrorVar
		$svm_status=$svm_status.OperationalState
		if($svm_status -eq "stopped"){
			Write-LogWarn "[$svm] can't be saved because it is in `"stopped`" state"
			continue
		}
		Write-Log "Create Backup Job for [$svm]" "Blue" -multithreaded
        $codeBackup=[scriptblock]::Create({
        param(

                [Parameter(Mandatory=$True)][string]$script_path,
                [Parameter(Mandatory=$True)][NetApp.Ontapi.Filer.C.NcController]$myPrimaryController,
                [Parameter(Mandatory=$True)][string]$myPrimaryVserver,
                [Parameter(Mandatory=$True)][string]$SVMTOOL_DB,
                [Parameter(Mandatory=$True)][String]$BackupDate,
		[Parameter(Mandatory=$True)][String]$LOGFILE,
                [Parameter(Mandatory=$True)][string]$LogLevelConsole,
                [Parameter(Mandatory=$True)][string]$LogLevelLogFile,
                [boolean]$NonInteractive

			)
      
      $ConsoleThreadingRequired=$true
			$Path=$env:PSModulePath.split(";")
			if($Path -notcontains $script_path){
				$Path+=$script_path
				$Path=[string]::Join(";",$Path)
				[System.Environment]::SetEnvironmentVariable('PSModulePath',$Path)
			}

			$module=import-module svmtools -PassThru
			if ( $module -eq $null ) {
					Write-Error "ERROR: Failed to load module SVMTOOLS"
					exit 1
			}
			$Global:STOP_TIMEOUT=360
			$Global:START_TIMEOUT=360

			$dir=split-path -Path $LOGFILE -Parent
			$file=split-path -Path $LOGFILE -Leaf
			$LOGFILE=($dir+'\'+$myPrimaryVserver+'\'+$file)


      # appenders (logfile, eventviewer & console)

      $guid = ([guid]::NewGuid()).Guid
      $masterLogFileAppender = create_rolling_log_appender -name "svmtool.log_$guid"  -file $LOGFILE -threshold $LogLevelLogFile
      $consoleAppender = create_console_appender -name "console_$guid" -threshold $LogLevelConsole

      # initialize console
      add_appender -loggerinstance "console_$guid" $masterLogFileAppender
      add_appender -loggerinstance "console_$guid" $consoleAppender
      set_log_level -loggerinstance "console_$guid" -level "All"
      $Global:ConsoleLog = get_logger -name "console_$guid"

      add_appender -loggerinstance "logonly_$guid" $masterLogFileAppender
      set_log_level -loggerinstance "logonly_$guid" -level "All"
      $Global:MasterLog = get_logger -name "logonly" 

      $Global:NonInteractive=$NonInteractive

      $module=get-module dataontap
      if(-not $module){
			    $module=import-module "$script_path\..\DataOntap" -PassThru
			    if ( $module -eq $null ) {
					    Write-LogError "ERROR: Failed to load module Netapp PSTK"
					    exit 1
			    }
      }

			check_create_dir -FullPath $LOGFILE -Vserver $myPrimaryVserver
			Write-Log "[$myPrimaryVserver] Log File is [$LOGFILE]"
			$Global:SVMTOOL_DB=$SVMTOOL_DB
			$Global:JsonPath=$($SVMTOOL_DB+"\"+$myPrimaryVserver+"\"+$BackupDate+"\")
			Write-LogDebug "[$myPrimaryVserver] Backup Folder is [$Global:JsonPath]"
			check_create_dir -FullPath $($Global:JsonPath+"backup.json") -Vserver $myPrimaryVserver

			Write-LogDebug "[$myPrimaryVserver] Backup Folder after check_create_dir is [$Global:JsonPath]"
            if ( ( $ret=create_vserver_dr -myPrimaryController $myPrimaryController -workOn $myPrimaryVserver -Backup -myPrimaryVserver $myPrimaryVserver -DDR $False -aggrMatchRegEx $AggrMatchRegex -nodeMatchRegEx $NodeMatchRegex -myDataAggr $DataAggr)[-1] -ne $True ){
				Write-LogDebug "create_vserver_dr return False [$ret]"
                flush_log4net -loggerinstance "console_$guid"
                flush_log4net -loggerinstance "logonly_$guid"
				return $False
			}
			Write-LogDebug "create_vserver_dr correctly finished [$ret]"
			Write-Log "[$myPrimaryVserver] Check Quota"
			$AllQuotaRulesList=Get-NcQuota -Controller $myPrimaryController -VserverContext $myPrimaryVserver -ErrorVariable ErrorVar 
    		if ( $? -ne $True ) { 
        		Write-LogDebug "ERROR: Get-NcQuota Failed"
                flush_log4net -loggerinstance "console_$guid"	
                flush_log4net -loggerinstance "logonly_$guid"
        		return $False
			}
			$AllQuotaRulesList | ConvertTo-Json -Depth 5 | Out-File -FilePath $($Global:JsonPath+"Get-NcQuota.json") -Encoding ASCII -Width 65535
			if( ($ret=get-item $($Global:JsonPath+"Get-NcQuota.json") -ErrorAction SilentlyContinue) -ne $null ){
				Write-LogDebug "$($Global:JsonPath+"Get-NcQuota.json") saved successfully"
			}else{
				Write-LogError "ERROR: Failed to saved $($Global:JsonPath+"Get-NcQuota.json")"
                flush_log4net -loggerinstance "console_$guid"
                flush_log4net -loggerinstance "logonly_$guid"
				return $False
			}
			Write-Log "[$myPrimaryVserver] Check Quota Policy"
			$AllQuotaPolicyList=Get-NcQuotaPolicy -Controller $myPrimaryController -VserverContext $myPrimaryVserver -ErrorVariable ErrorVar 
    		if ( $? -ne $True ) { 
				Write-LogDebug "ERROR: Get-NcQuotaPolicy Failed"
                flush_log4net -loggerinstance "console_$guid"
                flush_log4net -loggerinstance "logonly_$guid"
				return $False
			}
			$AllQuotaPolicyList | ConvertTo-Json -Depth 5 | Out-File -FilePath $($Global:JsonPath+"Get-NcQuotaPolicy.json") -Encoding ASCII -Width 65535
			if( ($ret=get-item $($Global:JsonPath+"Get-NcQuotaPolicy.json") -ErrorAction SilentlyContinue) -ne $null ){
				Write-LogDebug "$($Global:JsonPath+"Get-NcQuotaPolicy.json") saved successfully"
			}else{
				Write-LogError "ERROR: Failed to saved $($Global:JsonPath+"Get-NcQuotaPolicy.json")"
                flush_log4net -loggerinstance "console_$guid"
                flush_log4net -loggerinstance "logonly_$guid"
				return $False
			}
            flush_log4net -loggerinstance "console_$guid"
            flush_log4net -loggerinstance "logonly_$guid"
            return $True

        })
        $BackupJob=[System.Management.Automation.PowerShell]::Create()
        ## $createVserverBackup=Get-Content Function:\create_vserver_dr -ErrorAction Stop
        ## $codeBackup=$createVserverBackup.Ast.Body.Extent.Text
        [void]$BackupJob.AddScript($codeBackup)
        [void]$BackupJob.AddParameter("script_path",$PSScriptRoot)
        [void]$BackupJob.AddParameter("myPrimaryController",$NcPrimaryCtrl)
        [void]$BackupJob.AddParameter("myPrimaryVserver",$svm)
		[void]$BackupJob.AddParameter("SVMTOOL_DB",$SVMTOOL_DB)
		[void]$BackupJob.AddParameter("BackupDate",$BackupDate)
		[void]$BackupJob.AddParameter("LOGFILE",$LOGFILE)
		[void]$BackupJob.AddParameter("LogLevelLogFile",$LogLevelLogFile)
        [void]$BackupJob.AddParameter("LogLevelConsole",$LogLevelConsole)
        [void]$BackupJob.AddParameter("NonInteractive",$NonInteractive)
		$BackupJob.RunspacePool=$RunspacePool_Backup
        $Handle=$BackupJob.BeginInvoke()
        $JobBackup = "" | Select-Object Handle, Thread, Name
        $JobBackup.Handle=$Handle
        $JobBackup.Thread=$BackupJob
		$JobBackup.Name=$svm
		<# if($JobBackup.Thread.InvocationStateInfo.State -eq "Failed"){
			$reason=$JobBackup.Thread.InvocationStateInfo.Reason
			Write-LogDebug "ERROR: Failed to invoke Backup Job [$svm] Reason: $reason"
			clean_and_exit 1
		}
		if($JobBackup.Thread.Streams.Error -ne $null){
			$reason=$JobBackup.Thread.Stream.Error
			Write-LogDebug "ERROR: Failed to invoke Backup Job [$svm] Reason: $reason"
			clean_and_exit 1
		} #>
		$Jobs_Backup+=$JobBackup
		$numJobBackup++
	}
    While (($Jobs_Backup | Where-Object {$_.Handle.IsCompleted -eq $True} | Measure-Object).Count -ne $numJobBackup){
        $JobRemain=$Jobs_Backup | Where-Object {$_.Handle.IsCompleted -eq $False}
		$Remaining=""
		$Remaining=$JobRemain.Name
		If ($Remaining.Length -gt 80){
			$Remaining = $Remaining.Substring(0,80) + "..."
		}
		$numberRemaining=($JobRemain | Measure-Object).Count
		if($numberRemaining -eq $null -or $numberRemaining -eq 0){
			$JobRemain
		}
		$percentage=[math]::round((($numJobBackup-$numberRemaining) / $numJobBackup) * 100)
		Write-Progress `
			-id 1 `
			-Activity "Waiting for all $numJobBackup Jobs to finish..." `
			-PercentComplete (((($Jobs_Backup.Count)-$numberRemaining) / $Jobs_Backup.Count) * 100) `
			-Status "$($($($Jobs_Backup | Where-Object {$_.Handle.IsCompleted -eq $False})).count) remaining task(s) : $Remaining [$percentage% done]"
	}
	ForEach ($JobBackup in $($Jobs_Backup | Where-Object {$_.Handle.IsCompleted -eq $True})){
        $jobname=$JobBackup.Name
        Write-log "$jobname finished" -color magenta
        $result_Backup=$JobBackup.Thread.EndInvoke($JobBackup.Handle)
		if($result_Backup.count -gt 0){
			$ret=$result_Backup[-1]
		}else{
			$ret=$result_Backup
		}
		if($ret -ne $True){
			Write-LogError "ERROR: Backup for SVM [$jobname]"
			Write-LogError "Check log"
		}
        #Write-LogDebug "result Backup Job [$jobname] = $result_Backup"
    }
    $RunspacePool_Backup.Close()
	$RunspacePool_Backup.Dispose()

    # end 
    $stopwatch.stop()
    Write-Log $("Finished - Script ran for {0}" -f $stopwatch.Elapsed.toString())
    clean_and_exit 0
}

if ( $Restore ) {
    $Run_Mode="Restore"
    Write-LogOnly "SVMTOOL Run Restore"
    if ((Test-Path $CONFFILE) -eq $True ) {
		$read_conf = read_config_file $CONFFILE
		if ( $read_conf -eq $null ){
        		Write-LogError "ERROR: read configuration file $CONFFILE failed"
        		clean_and_exit 1
        }
        $SVMTOOL_DB=$read_conf.Get_Item("SVMTOOL_DB")
    }
    if($SVMTOOL_DB.Length -gt 0){
        Write-Log "Restore from Cluster [$Restore] from Backup Folder [$SVMTOOL_DB]"
    }else{
		Write-Error "ERROR: No Backup Folder configured, check configuration file [$CONFFILE] for item [SVMTOOL_DB]"
		clean_and_exit 1
	}
    $RESTOREALLSVM=$False
    if($Vserver.Length -eq 0){ 
        Write-Log "No SVM selected, will restore all SVM availables in Backup folder for Cluster [$Restore]"
        $RESTOREALLSVM=$True
    }else{
        Write-LogDebug "Restore SVM [$Vserver] from Backup for Cluster [$Restore]"
	}
	if($Destination.length -lt 1){
		$Destination=$Restore
		Write-LogDebug "No Destination specified. Will restore on source Cluster [$Destination]"
	}else{
		Write-LogDebug "Will restore on new Cluster [$Destination]"	
	}
    $myCred=get_local_cDotcred ($Destination)
    $tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$Destination] with login [$tmp_str]"
	Write-LogDebug "connect_cluster -myController $Destination -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster -myController $Destination -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$Destination]" 
		clean_and_exit 1
    }
    if($RESTOREALLSVM -eq $True){
		if(($ALLSVM=(Get-ChildItem $SVMTOOL_DB).Name) -eq $null){
			$Return = $False ; throw "ERROR: Get-ChildItem failed for [$SVMTOOL_DB]`nERROR: no Backup available"
		}
        if($AllSVM){
            $SVMList=$AllSVM
        }
    }else{
		if((Test-Path $SVMTOOL_DB) -eq $null){
			$Return = $False ; throw "ERROR: no Backup available for [$Restore] inside [$SVMTOOL_DB]"	
		}else{
			$SVMList=@($Vserver)
		}
    }
    #Loop to backup all SVM in List . Loop in RunspacePool
    $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $RunspacePool_Restore=[runspacefactory]::CreateRunspacePool(1, $Global:NumberOfLogicalProcessor, $iss, $Host)
    $RunspacePool_Restore.Open()
    [System.Collections.ArrayList]$jobs = @()
    $stopwatch=[system.diagnostics.stopwatch]::StartNew()
    $SVMcount=$SVMList.Count
	$Jobs_Restore = @()
	$numJobRestore=0
    foreach($svm in $SVMList){
		Write-Log "Select Backup Date for [$svm]"
		$BackupAvailable=Get-ChildItem $($SVMTOOL_DB+"\"+$svm) | Sort-Object -Property CreationTime
		if($BackupAvailable -eq $null){
			Write-Error "ERROR: No Backup available for [$svm]"
			next
		}else{
			$ans=$null
			if($SelectBackupDate -eq $True){
				$listBackupAvailable=($BackupAvailable | select-object Name).Name
				while($ans -eq $null){
					Write-Host "Select a Backup Date for [$svm] : "
					$i=1
					foreach($date in $listBackupAvailable){
						$numFiles=(Get-ChildItem $($SVMTOOL_DB+"\"+$svm+"\"+$date+"\") | Measure-Object).Count
						$datetime=[datetime]::parseexact($date,"yyyyMMddHHmmss",$null)
						Format-ColorBrackets "`t[$i] : [$datetime] [$numFiles Files]" -FirstIsSpecial
						$i++
					}
					$Query="Please select Backup from (1.."+$listBackupAvailable.count+")"
					$ans=Read-HostDefault -question $Query -default $listBackupAvailable.count
					$ans=[int]$ans/1
					if(($ans -notmatch "[0-9]") -or ($ans -lt 1 -or $ans -gt $listBackupAvailable.count)){Write-Warning "Bad input";$ans=$null}
				}
				$date=$listBackupAvailable[$ans-1]
			}else{
				# display lastbackup automatically selected for each SVM (with #files inside folder)
				$LastBackup=$BackupAvailable[-1]
				$date=$LastBackup.Name
				$datetime=[datetime]::parseexact($date,"yyyyMMddHHmmss",$null)
				$numFiles=(Get-ChildItem $($SVMTOOL_DB+"\"+$svm+"\"+$date+"\") | Measure-Object).Count
				Write-Log "[$svm] Last Backup date is [$datetime] with [$numFiles Files]" -firstValueIsSpecial
			}
		}
		$JsonPath=$($SVMTOOL_DB+"\"+$svm+"\"+$date+"\")
		Write-Log "[$svm] Create Restore Job from [$JsonPath]"
		$codeRestore=[scriptblock]::Create({
            param(
                [Parameter(Mandatory=$True)][string]$script_path,
                [Parameter(Mandatory=$True)][string]$SourceVserver,
		[Parameter(Mandatory=$True)][string]$SVMTOOL_DB,
                [Parameter(Mandatory=$True)][String]$JsonPath,
                [Parameter(Mandatory=$True)][String]$LOGFILE,
                [Parameter(Mandatory=$True)][NetApp.Ontapi.Filer.C.NcController]$DestinationController,
                [Parameter(Mandatory=$True)][string]$VOLTYPE,
		[Parameter(Mandatory=$False)][pscredential]$DefaultLocalUserCredentials,
		[Parameter(Mandatory=$False)][pscredential]$ActiveDirectoryCredentials,
		[Parameter(Mandatory=$False)][string]$TemporarySecondaryCifsIp,
		[Parameter(Mandatory=$False)][string]$SecondaryCifsLifMaster,
                [Parameter(Mandatory=$False)][string]$RootAggr,
                [Parameter(Mandatory=$False)][string]$DataAggr,        
		[Parameter(Mandatory=$True)][string]$LogLevelConsole,
                [Parameter(Mandatory=$True)][string]$LogLevelLogFile,
                [boolean]$NonInteractive
            )
            $Global:ConsoleThreadingRequired=$true
			$Path=$env:PSModulePath.split(";")
			if($Path -notcontains $script_path){
				$Path+=$script_path
				$Path=[string]::Join(";",$Path)
				[System.Environment]::SetEnvironmentVariable('PSModulePath',$Path)
			}
			$module=import-module svmtools -PassThru
			if ( $module -eq $null ) {
					Write-Error "ERROR: Failed to load module SVMTOOLS"
					exit 1
			}
			$Global:STOP_TIMEOUT=360
			$Global:START_TIMEOUT=360
			$dir=split-path -Path $LOGFILE -Parent
			$file=split-path -Path $LOGFILE -Leaf
			$LOGFILE=($dir+'\'+$SourceVserver+'\'+$file)

            # appenders (logfile, eventviewer & console)

            $guid = ([guid]::NewGuid()).Guid
            $masterLogFileAppender = create_rolling_log_appender -name "svmtool.log_$guid"  -file $LOGFILE -threshold $LogLevelLogFile
            $consoleAppender = create_console_appender -name "console_$guid" -threshold $LogLevelConsole

            # initialize console
            add_appender -loggerinstance "console_$guid" $masterLogFileAppender
            add_appender -loggerinstance "console_$guid" $consoleAppender
            set_log_level -loggerinstance "console_$guid" -level "Debug"
            $Global:ConsoleLog = get_logger -name "console_$guid"

            add_appender -loggerinstance "logonly_$guid" $masterLogFileAppender
            set_log_level -loggerinstance "logonly_$guid" -level "All"
            $Global:MasterLog = get_logger -name "logonly" 

            $Global:NonInteractive=$NonInteractive

			check_create_dir -FullPath $LOGFILE -Vserver $SourceVserver

            $Global:SVMTOOL_DB=$SVMTOOL_DB
			$Global:JsonPath=$JsonPath
			$Global:VOLUME_TYPE=$VOLTYPE
			$Global:RootAggr=$RootAggr
			$Global:DataAggr=$DataAggr
			$Global:DefaultLocalUserCredentials=$DefaultLocalUserCredentials
			$Global:ActiveDirectoryCredentials=$ActiveDirectoryCredentials
			check_create_dir -FullPath $Global:JsonPath -Vserver $SourceVserver
			$DestinationCluster=$DestinationController.Name
			Write-LogDebug ""
			Write-LogDebug "Restore [$SourceVserver] on Cluster [$DestinationCluster]"
			Write-LogDebug "LOGFILE [$LOGFILE]"
			Write-LogDebug "SVMTOOL_DB [$Global:SVMTOOL_DB]"
			Write-LogDebug "JsonPath [$Global:JsonPath]"
			Write-LogDebug "SourceVserver [$SourceVserver]"
			Write-LogDebug "DestinationController [$DestinationController]"
			Write-LogDebug "VOLUME_TYPE [$Global:VOLUME_TYPE]"
			Write-LogDebug "RootAggr [$Global:RootAggr]"
			Write-LogDebug "DataAggr [$Global:DataAggr]"
        if ( ( $ret=create_vserver_dr -myPrimaryVserver $SourceVserver -mySecondaryController $DestinationController -workOn $SourceVserver -mySecondaryVserver $SourceVserver -Restore -DDR $False -aggrMatchRegEx $AggrMatchRegex -nodeMatchRegEx $NodeMatchRegex -myDataAggr $DataAggr)[-1] -ne $True ){

				Write-LogDebug "ERROR in create_vserver_dr [$ret]"
                #return $False
			}
			if($Global:VOLUME_TYPE -eq "RW"){
				# in restore mode force update snapshot policy on all destinations volumes
				$Global:ForceUpdateSnapPolicy=$True
				if ( ( $ret=set_vol_options_from_voldb -myVserver $SourceVserver -myController $DestinationController -Restore) -ne $True ){
					Write-LogDebug "ERROR in create_vserver_dr [$ret]"
					#return $False
				}
				if ( ($ret=restore_quota -myController $DestinationController -myVserver $SourceVserver) -ne $True){
					Write-LogDebug "restore_quota return False [$ret]"
					#return $False
				}
			}else{
				Write-Log "Once Data restored via SnapMirror on DP destinations volumes, update as necessarry Snapshot Policy and Efficiency"
			}
            flush_log4net -loggerinstance "console_$guid"
            flush_log4net -loggerinstance "logonly_$guid"
            return $True
        })
        $RestoreJob=[System.Management.Automation.PowerShell]::Create()
        ## $createVserverVackup=Get-Content Function:\create_vserver_dr -ErrorAction Stop
        ## $codeRestore=$createVserverVackup.Ast.Body.Extent.Text
        [void]$RestoreJob.AddScript($codeRestore)
        [void]$RestoreJob.AddParameter("script_path",$PSScriptRoot)
        [void]$RestoreJob.AddParameter("SourceVserver",$svm)
		[void]$RestoreJob.AddParameter("SVMTOOL_DB",$SVMTOOL_DB)
		[void]$RestoreJob.AddParameter("JsonPath",$JsonPath)
		[void]$RestoreJob.AddParameter("LOGFILE",$LOGFILE)
		[void]$RestoreJob.AddParameter("DestinationController",$NcSecondaryCtrl)
		[void]$RestoreJob.AddParameter("DefaultLocalUserCredentials",$DefaultLocalUserCredentials)
		[void]$RestoreJob.AddParameter("ActiveDirectoryCredentials",$ActiveDirectoryCredentials)
		[void]$RestoreJob.AddParameter("TemporarySecondaryCifsIp",$TemporarySecondaryCifsIp)
		[void]$RestoreJob.AddParameter("SecondaryCifsLifMaster",$SecondaryCifsLifMaster)
		[void]$RestoreJob.AddParameter("RootAggr",$Global:RootAggr)
		[void]$RestoreJob.AddParameter("DataAggr",$Global:DataAggr)
		if($RW -eq $True){
			[void]$RestoreJob.AddParameter("VOLTYPE","RW")
		}else{
			[void]$RestoreJob.AddParameter("VOLTYPE","DP")
		}
		[void]$RestoreJob.AddParameter("LogLevelLogFile",$LogLevelLogFile)
        [void]$RestoreJob.AddParameter("LogLevelConsole",$LogLevelConsole)
        [void]$RestoreJob.AddParameter("NonInteractive",$NonInteractive)
		$RestoreJob.RunspacePool=$RunspacePool_Restore
        $Handle=$RestoreJob.BeginInvoke()
        $JobRestore = "" | Select-Object Handle, Thread, Name, Log
        $JobRestore.Handle=$Handle
        $JobRestore.Thread=$RestoreJob
		$JobRestore.Name=$svm
		$dir=split-path -Path $LOGFILE -Parent
		$file=split-path -Path $LOGFILE -Leaf
		$LOGJOB=($dir+'\'+$svm+'\'+$file)
		$JobRestore.Log=$LOGJOB
		if($JobRestore.Thread.InvocationStateInfo.State -eq "Failed"){
			$reason=$JobRestore.Thread.InvocationStateInfo.Reason
			Write-LogDebug "ERROR: Failed to invoke Restore Job [$svm] Reason: [$reason]"
			clean_and_exit 1
		}
		if($JobRestore.Thread.Streams.Error -ne $null){
			$reason=$JobRestore.Thread.Stream.Error
			Write-LogDebug "ERROR: Failed to invoke Restore Job [$svm] Reason: [$reason]"
			clean_and_exit 1
		}
		$Jobs_Restore+=$JobRestore
		$numJobRestore++
    }
	While (@($Jobs_Restore | Where-Object {$_.Handle.IsCompleted -eq $True} | Measure-Object).Count -ne $numJobRestore){
        $JobRemain=$Jobs_Restore | Where-Object {$_.Handle.IsCompleted -eq $False}
		$Remaining=""
		$Remaining=$JobRemain.Name
		If ($Remaining.Length -gt 80){
			$Remaining = $Remaining.Substring(0,80) + "..."
		}
		$numberRemaining=($JobRemain | Measure-Object).Count
		if($numberRemaining -eq $null -or $numberRemaining -eq 0){
			$JobRemain
		}
		$percentage=[math]::round((($numJobRestore-$numberRemaining) / $numJobRestore) * 100)
		Write-Progress `
			-id 1 `
			-Activity "Waiting for all $numJobRestore Jobs to finish..." `
			-PercentComplete (((($Jobs_Restore.Count)-$numberRemaining) / $Jobs_Restore.Count) * 100) `
			-Status "$($($($Jobs_Restore | Where-Object {$_.Handle.IsCompleted -eq $False})).count) remaining : $Remaining [$percentage% done]"
	}
	ForEach ($JobRestore in $($Jobs_Restore | Where-Object {$_.Handle.IsCompleted -eq $True})){
        $jobname=$JobRestore.Name
        Write-logDebug "$jobname finished"
        $result_Restore=$JobRestore.Thread.EndInvoke($JobRestore.Handle)
		if($result_Restore.count -gt 0){
			$ret=$result_Restore[-1]
		}else{
			$ret=$result_Restore
		}
		if($ret -ne $True){
			Write-LogError "ERROR: Restore for SVM [$jobname]:[$ret]:[$result_Restore]"
			$LOGPATH=$JobRestore.Log
			Write-LogError "Check log [$LOGPATH]"
		}
        #Write-LogDebug "result Restore Job [$jobname] = $result_Restore"
    }
    $RunspacePool_Restore.Close()
	$RunspacePool_Restore.Dispose()
    # end 
    $stopwatch.stop()
    Write-Log $("Finished - Script ran for {0}" -f $stopwatch.Elapsed.toString())
    clean_and_exit 0
}

if ( ( Test-Path $CONFFILE ) -eq $False )  {
        Write-LogError "ERROR: instance [$instance] not found please run setup option" 
	clean_and_exit 1
}

if ( ( $Vserver -eq $null ) -or ( $Vserver -eq "" ) ) { 
	Write-LogError "ERROR: Missing an argument for parameter 'Vserver'" 
	Write-LogError "ERROR: Please run svmdr -help for information" 
	Clean_and_exit 1 
}

# Read configuration file
$read_conf = read_config_file $CONFFILE ;
if ( $read_conf -eq $null ){
        Write-LogError "ERROR: read configuration file $CONFFILE failed" 
        clean_and_exit 1 ;
}

$PRIMARY_CLUSTER=$read_conf.Get_Item("PRIMARY_CLUSTER") ;
if ( $PRIMARY_CLUSTER -eq $Null ) {
	Write-LogError "ERROR: unable to find PRIMARY_CLUSTER in $CONFFILE"
        clean_and_exit 1 ;
}
$SECONDARY_CLUSTER=$read_conf.Get_Item("SECONDARY_CLUSTER") ;
if ( $SECONDARY_CLUSTER -eq $Null ) {
	Write-LogError "ERROR: unable to find SECONDARY_CLUSTER in $CONFFILE"
        clean_and_exit 1 ;
}

if ($PRIMARY_CLUSTER -eq $SECONDARY_CLUSTER) 
{ 
    $SINGLE_CLUSTER = $True
    Write-LogDebug "Detected SINGLE_CLUSTER Configuration"
}

# Read Vserver configuration file
$VCONFFILE=$CONFDIR + $Vserver + '.conf'
if ($RemoveDRconf) {
    $Run_Mode="RemoveDRconf"
	Write-LogOnly "SVMTOOL RemoveDRconf"
	if ((Test-Path $VCONFFILE ) -eq $True ) {
		Remove-Item $VCONFFILE
        Write-Log "$VCONFFILE removed successfully..." -color green
	}else{
        Write-Log "No such config [$VCONFFILE] found..." -color yellow
    }
        clean_and_exit 1 ;
}

Write-LogDebug "VCONFFILE [$VCONFFILE]"
$read_vconf = read_config_file $VCONFFILE

if ( ( $Setup ) -or ( $read_vconf -eq $null ) ) {
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster -myController $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster -myController $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1 ;
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster -myController $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster -myController $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1 ;
	}
	$VserverPeerList= get_vserver_peer_list -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver
	if ( $VserverPeerList ) {
		Write-Log "$Vserver has already existing vserver peer to the cluster [$NcSecondaryCtrl]"
		foreach ( $VserverPeer in $VserverPeerList ) {
			Write-Log "[$Vserver] -> [$VserverPeer]"
		}
	}
	create_vserver_config_file_cli -Vserver $Vserver -ConfigFile $VCONFFILE -VserverDr $VserverDr -QuotaDr:$QuotaDR
	$read_vconf = read_config_file $VCONFFILE
	if ( $read_vconf -eq $null ){
		Write-LogError "ERROR: Failed to create $VCONFFILE "
		clean_and_exit 2
	}
	if ( ! $ConfigureDR ) {
		clean_and_exit 0
	}
}

$VserverDR=$read_vconf.Get_Item("VserverDR")
if ( $Vserver -eq $Null ) {
	Write-LogError "ERROR: unable to find VserverDR in $VCONFFILE"
        clean_and_exit 1 ;
}
$AllowQuotaDR=$read_vconf.Get_Item("AllowQuotaDR")
$SVMTOOL_DB=$read_conf.Get_Item("SVMTOOL_DB")
$Global:SVMTOOL_DB=$SVMTOOL_DB
$Global:CorrectQuotaError=$CorrectQuotaError
$Global:ForceDeleteQuota=$ForceDeleteQuota
$Global:ForceActivate=$ForceActivate
$Global:ForceRecreate=$ForceRecreate
$Global:ForceRestart=$ForceRestart
$Global:ForceUpdateSnapPolicy=$ForceUpdateSnapPolicy
$Global:SelectVolume=$SelectVolume
$Global:IgnoreQtreeExportPolicy=$IgnoreQtreeExportPolicy
$Global:AllowQuotaDr=$AllowQuotaDr
$Global:IgnoreQuotaOff=$IgnoreQuotaOff
$Global:DataAggr=$DataAggr

Write-LogDebug "PRIMARY_CLUSTER:            		 [$PRIMARY_CLUSTER]" 
Write-LogDebug "SECONDARY_CLUSTER:          		 [$SECONDARY_CLUSTER]" 
Write-LogDebug "VSERVER                     		 [$Vserver]" 
Write-LogDebug "VSERVER DR                  		 [$VserverDR]" 
Write-LogDebug "QUOTA DR                    		 [$Global:AllowQuotaDr]" 
Write-LogDebug "SVMTOOL DB                           [$Global:SVMTOOL_DB]"
Write-LogDebug "OPTION IgnoreQuotaOff       		 [$Global:IgnoreQuotaOff]"
Write-LogDebug "OPTION CorrectQuotaError    		 [$Global:CorrectQuotaError]"
Write-LogDebug "OPTION ForceDelete          		 [$Global:ForceDeleteQuota]"
Write-LogDebug "OPTION ForceActivate        		 [$Global:ForceActivate]"
Write-LogDebug "OPTION ForceRecreate        		 [$Global:ForceRecreate]"
Write-LogDebug "OPTION ForceRestart        		     [$Global:ForceRestart]"
Write-LogDebug "OPTION ForceUpdateSnapPolicy         [$Global:ForceUpdateSnapPolicy]"
Write-LogDebug "OPTION AlwaysChooseDataAggr 		 [$Global:AlwaysChooseDataAggr]"
Write-LogDebug "OPTION SelectVolume         		 [$Global:SelectVolume]"
Write-LogDebug "OPTION IgnoreQtreeExportPolicy       [$Global:IgnoreQtreeExportPolicy]"

if ( $ShowDR ) {
    $Run_Mode="ShowDR"
	Write-LogOnly "SVMTOOL ShowDR"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster -myController $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster -myController $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
		$NcPrimaryCtrl =  $null
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster -myController $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster -myController $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
		$NcSecondaryCtrl = $null
	}
	Write-LogDebug "show_vserver_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR"
    $ret=show_vserver_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR -MSID:$MSID -Lag:$Lag -Schedule:$Schedule
	clean_and_exit 0
}

if ( $ConfigureDR ) {
    $Run_Mode="ConfigureDR"
	Write-LogOnly "SVMTOOL ConfigureDR"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster -myController $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster -myController $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster -myController $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster -myController $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
    $DestVserver=Get-NcVserver -Vserver $VserverDR -Controller $NcSecondaryCtrl -ErrorVariable ErrorVar
    if ( $? -ne $True ) { $Return = $False ; throw "ERROR: Get-NcVserver failed [$ErrorVar]" }
    if($DestVserver.IsConfigLockedForChanges -eq $True){
        Write-logDebug "Unlock-NcVserver -Vserver $VserverDR -Force -Confirm:$False -Controller $NcSecondaryCtrl"
        $ret=Unlock-NcVserver -Vserver $VserverDR -Force -Confirm:$False -Controller $NcSecondaryCtrl -ErrorVariable ErrorVar
        if ( $? -ne $True ) { $Return = $False ; throw "ERROR: Dest Vserver [$VserverDR] has its config locked. Unlock-NcVserver failed [$ErrorVar]" }
    }
	if ( ( $ret=check_cluster_peer -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl ) -ne $True ) {
		Write-LogError "ERROR: check_cluster_peer" 
		clean_and_exit 1
	}
	if ( $XDPPolicy -ne "MirrorAllSnapshots" ){
		$ret=Get-NcSnapmirrorPolicy -Name $XDPPolicy -Controller $NcSecondaryCtrl -ErrorVariable ErrorVar
		if( $? -ne $True -or $ret.count -eq 0 ){
			Write-LogDebug "XDPPolicy [$XDPPolicy] does not exist on [$SECONDARY_CLUSTER]. Will use MirrorAllSnapshots as default Policy"
            Write-Warning "XDPPolicy [$XDPPolicy] does not exist on [$SECONDARY_CLUSTER]. Will use [MirrorAllSnapshots] as default Policy for all XDP relationships"
			$XDPPolicy="MirrorAllSnapshots"
		}
	}

	if ( ( $ret=create_vserver_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR -DDR ($DRfromDR.isPresent) -XDPPolicy $XDPPolicy -aggrMatchRegEx $AggrMatchRegex -nodeMatchRegEx $NodeMatchRegex -myDataAggr $DataAggr -TemporarySecondaryCifsIp $TemporarySecondaryCifsIp -SecondaryCifsLifMaster $SecondaryCifsLifMaster)[-1] -ne $True ) {
		clean_and_exit 1

	}
  	if ( ( $ret=svmdr_db_switch_datafiles -myController $NcPrimaryCtrl -myVserver $Vserver ) -eq $false ) {
        	Write-LogError "ERROR: Failed to switch SVMTOOL_DB datafiles" 
        	clean_and_exit 1
  	}
    # Verify if CIFS Service is Running if yes stop it
	$CifService = Get-NcCifsServer  -VserverContext  $VserverDR -Controller $NcSecondaryCtrl  -ErrorVariable ErrorVar
	if ( $? -ne $True ) { $Return = $False ; throw "ERROR: Get-NcCifsServer failed [$ErrorVar]" }
	if ( $CifService -eq $null ) {
		Write-Log "[$VserverDR] No CIFS services"
	} else {
		if ( $CifService.AdministrativeStatus -eq 'up' ) {
			Write-LogDebug "stop-NcCifsServer -VserverContext $VserverDR -Controller $NcSecondaryCtrl -Confirm:$False"
			$out=Stop-NcCifsServer -VserverContext $VserverDR -Controller $NcSecondaryCtrl  -ErrorVariable ErrorVar -Confirm:$False
			if ( $? -ne $True ) {
				Write-LogError "ERROR: Failed to disable CIFS on Vserver [$VserverDR]" 
				$Return = $False
			}
		}
	}
	if ( ( $ret=save_vol_options_to_voldb -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne $True ) {
		Write-LogError "ERROR: save_vol_options_to_voldb failed"
		clean_and_exit 1
	}

	Write-LogDebug "AllowQuotaDR [$AllowQuotaDr]"
	if ( $AllowQuotaDR -eq "True" ) {
		Write-Log "[$VserverDR] Save quota policy rules to SVMTOOL_DB [$SVMTOOL_DB]" -firstValueIsSpecial
		if ( ( $ret=save_quota_rules_to_quotadb -myPrimaryController $NcPrimaryCtrl -myPrimaryVserver $Vserver -mySecondaryController $NcSecondaryCtrl -mySecondaryVserver $VserverDR ) -ne $True ) {
 			Write-LogError "ERROR: save_quota_rules_to_quotadb failed"
 			clean_and_exit 1
		}
	}
	clean_and_exit 0
}

if ( $DeleteDR ) {
    $Run_Mode="DeleteDR"
	Write-LogOnly "SVMTOOL DeleteDR"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred  -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
    # if ( ( $ret=analyse_junction_path -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne $True ) {
    	# Write-LogError "ERROR: analyse_junction_path" 
		# clean_and_exit 1
	# }
	if ( ( $ret=remove_vserver_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -eq $False ) {
		Write-LogError "ERROR: remove_vserver_dr: Unable to remove Vserver [$VserverDR]" 
		clean_and_exit 1
	}
	clean_and_exit 0
}

if($Migrate){
    $Run_Mode="Migrate"
    Write-LogOnly "SVMTOOL Migrate"
    # Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$PrimaryClusterName=$NcPrimaryCtrl.Name
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$SecondaryClusterName=$NcSecondaryCtrl.Name
	# if ( ( $ret=analyse_junction_path -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne $True ) {
    	# Write-LogError "ERROR: analyse_junction_path" 
		# clean_and_exit 1
	# }
    Write-Warning "SVMTOOL script does not manage FCP configuration"
    Write-Warning "You will have to backup and recreate all these configurations manually after the Migrate step"
    Write-Warning "Files Locks are not migrated during the Migration process"
    $ASK_WAIT=Read-HostOptions -question "[$Vserver] Have all clients saved their work ?" -options "y/n" -default "y"
    if($ASK_WAIT -eq 'y'){
        Write-LogDebug "Clients ready to migrate. User choose to continue migration procedure"
		Write-Log "[$VserverDR] Run last UpdateDR" -firstValueIsSpecial
		if ( ( $ret=create_update_cron_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl ) -ne $True ) {
			Write-LogError "ERROR: create_update_cron_dr"
		}
		if ( ( $ret=create_update_snap_policy_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR) -ne $True ) {
			Write-LogError "ERROR: create_update_snap_policy_dr"
		}

		if ( ( $ret=check_cluster_peer -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl ) -ne $True ) {
			Write-LogError "ERROR: check_cluster_peer failed"
			clean_and_exit 1
		}

		if ( ( $ret=update_cifs_usergroup -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR -NoInteractive) -ne $True ) {
			    Write-LogError "ERROR: update_cifs_usergroup failed"   
		}

		if ( ($ret=update_vserver_dr -myDataAggr $DataAggr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR -DDR ($DRfromDR.IsPresent) -aggrMatchRegEx $AggrMatchRegex -nodeMatchRegEx $NodeMatchRegex ) -ne $True ) {
			Write-LogError "ERROR: update_vserver_dr failed" 
			clean_and_exit 1

		}


		# if ( $MirrorSchedule ) {
			# Write-LogDebug "Flag MirrorSchedule"
		# }
		if ( ( $ret=wait_snapmirror_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne $True ) 
		{ 
			Write-LogError  "ERROR: wait_snapmirror_dr failed"  
		}
		if ( ( $ret=break_snapmirror_vserver_dr -myController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne $True ) {
			Write-LogError "ERROR: Unable to break all relations from Vserver [$VserverDR] on [$SecondaryClusterName]"
			clean_and_exit 1
		}
		# Remove Reverse SnapMirror Relationship if exist
		if ( ( $ret=remove_snapmirror_dr -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver	 ) -ne $True ) { 
			Write-LogError "ERROR: remove_snapmirror_dr failed"
			clean_and_exit 1
		}
		# Remove SnapMirror Relationship 
		if ( ( $ret=remove_snapmirror_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR -NoRelease) -ne $True ) {
			Write-LogError "ERROR: remove_snapmirror_dr failed" 
			clean_and_exit 1
		}
		# Restamp MSID destination volume

		# if ( ( $ret=restamp_msid -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDr) -ne $True) {
		# 	Write-LogError "ERROR: restamp_msid failed"
		# 	clean_and_exit 1
		# }
        $ASK_MIGRATE=Read-HostOptions -question "IP and Services will switch now for [$Vserver]. Ready to go ?" -options "y/n" -default "y"

        if($ASK_MIGRATE -eq 'y'){
		    if ( ( $ret=migrate_lif -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR) -ne $True ) {
			    Write-LogError "ERROR: migrate_lif failed"
			    clean_and_exit 1
		    }

		    if ( ( $ret=migrate_cifs_server -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR -NoInteractive) -ne $True ) {
			    Write-LogError "ERROR: migrate_cifs_server failed"
			    clean_and_exit 1
		    }
		    if (($ret=set_all_lif -mySecondaryVserver $VserverDR -myPrimaryVserver $Vserver -mySecondaryController $NcSecondaryCtrl  -myPrimaryController $NcPrimaryCtrl -state up -AfterMigrate) -ne $True ) {
				Write-LogError "ERROR: Failed to set all lif up on [$VserverDR]"
				clean_and_exit 1
			}
            #if (($ret=set_all_lif -myVserver $VserverDR -myController $NcSecondaryCtrl -state down) -ne $True ) {
            #    Write-LogError "ERROR: Failed to set all lif down on [$VserverDR]"
            #    clean_and_exit 1
            #}
		    # Verify if NFS service is Running 
		    Write-LogDebug "Get-NcNfsService -VserverContext $VserverDR -Controller $NcSecondaryCtrl"
		    $NfsService = Get-NcNfsService -VserverContext $VserverDR -Controller $NcSecondaryCtrl  -ErrorVariable ErrorVar
		    if ( $? -ne $True ) { $Return = $False ; throw "ERROR: Get-NcNfsService failed [$ErrorVar]" }
		    if ( $NfsService -eq $null ) {
			    Write-Log "[$VserverDR] No NFS services in vserver"
		    } else {
			    if ( $NfsService.GeneralAccess -ne $True ) {
				    Write-Log "[$VserverDR] Enable NFS"
				    Write-LogDebug "Enable-NcNfs -VserverContext $VserverDR -Controller $NcSecondaryCtrl"
				    $out=Enable-NcNfs -VserverContext $VserverDR -Controller $NcSecondaryCtrl  -ErrorVariable ErrorVar -Confirm:$False
				    if ( $? -ne $True ) {
					    Write-warning "ERROR: Failed to enable NFS on Vserver [$VserverDR] [ErrorVar]"
					    Write-LogError "ERROR: Failed to enable NFS on Vserver [$VserverDR]" 
				    }
                    Write-LogDebug "Disable-NcNfs -VserverContext $VserverDR -Controller $NcPrimaryCtrl"
				    $out=Disable-NcNfs -VserverContext $Vserver -Controller $NcPrimaryCtrl  -ErrorVariable ErrorVar -Confirm:$False
				    if ( $? -ne $True ) {
					    Write-warning "ERROR: Failed to disable NFS on Vserver [$VserverDR] [ErrorVar]"
					    Write-LogError "ERROR: Failed to disable NFS on Vserver [$VserverDR]" 
				    }
			    }
		    }

		    # Verify if ISCSI service is Running 
		    Write-LogDebug "Get-NcIscsiService -VserverContext $VserverDR -Controller $NcSecondaryCtrl"
		    $IscsiService = Get-NcIscsiService -VserverContext $VserverDR -Controller $NcSecondaryCtrl  -ErrorVariable ErrorVar
		    if ( $? -ne $True ) { $Return = $False ; throw "ERROR: Get-NcIscsiService failed [$ErrorVar]" }
		    if ( $IscsiService -eq $null ) {
			    Write-Log "[$VserverDR] No iSCSI services in Vserver"
		    } else {
			    if ( $IscsiService.IsAvailable -ne $True ) {
				    Write-Log "[$VserverDR] Enable iSCSI service on Vserver"
				    Write-LogDebug "Enable-NcIscsi -VserverContext $VserverDR -Controller $NcSecondaryCtrl"
				    $out=Enable-NcIscsi -VserverContext $VserverDR -Controller $NcSecondaryCtrl  -ErrorVariable ErrorVar -Confirm:$False
				    if ( $? -ne $True ) {
					    Write-warning "ERROR: Failed to enable iSCSI on Vserver [$VserverDR] [ErrorVar]"
					    Write-LogError "ERROR: Failed to enable iSCSI on Vserver [$VserverDR] [ErrorVar]" 
				    }
			    }
		    }
		    Write-Log "[$Vserver] has been migrated on destination cluster [$SecondaryClusterName]"
		    Write-Log "[$Vserver] Users can now connect on destination"
            if ( ( $ret=set_vol_options_from_voldb -myController $NcSecondaryCtrl -myVserver $VserverDR -NoCheck) -ne $True ) {
                Write-LogError "ERROR: set_vol_options_from_voldb failed"
            }
            #if ( ( $ret=set_shareacl_options_from_shareacldb -myController $NcSecondaryCtrl -myVserver $VserverDR -NoCheck) -ne $True ) {
            #    Write-LogError "ERROR: set_shareacl_options_from_shareacldb"
            #}
            if ( $AllowQuotaDR -eq "True" ) {
                if ( ( $ret=create_quota_rules_from_quotadb -myController $NcSecondaryCtrl -myVserver $VserverDR -NoCheck ) -ne $True ) {
                    Write-LogError "ERROR: create_quota_rules_from_quotadb failed"
                }
            }
            $defaultanswer = if($DeleteSource){"y"}else{"n"}
		    $ASK_WAIT2=Read-HostOptions -question "Do you want to delete Vserver [$Vserver] on source cluster [$PrimaryClusterName] ?" -options "y/n" -default $defaultanswer
            if($ASK_WAIT2 -eq 'y'){

                if ( ( $ret=remove_snapmirror_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR) -ne $True ) {
			        Write-LogError "ERROR: remove_snapmirror_dr failed" 
			        clean_and_exit 1
		        }

                if ( ( remove_vserver_peer -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne $True ) {
		            Write-LogError "ERROR: remove_vserver_peer failed" 
		            return $false
	            }

		        Write-Log "[$VserverDR] Renamed to [$Vserver]"
		        Write-LogDebug "Rename-NcVserver -Name $VserverDR -NewName $Vserver -Controller $NcSecondaryCtrl"
		        $out=Rename-NcVserver -Name $VserverDR -NewName $Vserver -Controller $NcSecondaryCtrl  -ErrorVariable ErrorVar
		        if ( $? -ne $True ) { throw "ERROR: Rename-NcVserver failed [$ErrorVar]"} 
			    Write-Log "Vserver [$Vserver] will be deleted on cluster [$PrimaryClusterName]"
			    if ( ( $ret=remove_vserver_source -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -eq $False ) {
		            Write-LogError "ERROR: remove_vserver_dr: Unable to remove vserver [$VserverDR]" 
		            clean_and_exit 1
	            }
                Write-Log "[$Vserver] completely removed on [$PrimaryClusterName]"
                clean_and_exit 0
            }else{
                Write-Log "User chose not to delete source Vserver [$Vserver] on Source Cluster [$PrimaryClusterName]"
			    Write-Log "Vserver [$Vserver] will only be stopped on [$PrimaryClusterName]"
                Write-Log "In this case the SVM object name on Destination Cluster [$SecondaryClusterName] is still [$VserverDR]"
                Write-Log "But CIFS identity is correctly migrated to [$Vserver]"
                Write-Log "Final rename will be done when [-DeleteSource] step will be executed, once you are ready to completely delete [$Vserver] on Source Cluster [$PrimaryClusterName]"
			    Write-LogDebug "Stop-NcVserver -Name $Vserver -Controller $NcPrimaryCtrl -Confirm:$False"
			    $ret=Stop-NcVserver -Name $Vserver -Controller $NcPrimaryCtrl -Confirm:$False -ErrorVariable ErrorVar
			    if ( $? -ne $True ) 
			    {
				    throw "ERROR: Stop-NcVerser failed [$ErrorVar]"
				    clean_and_exit 1
			    } 
            }
        }else{
            Write-Log "[$Vserver] Migration process has been stopped by user"
            Write-Log "[$Vserver] You could restart the [Migrate] step when ready"
            Write-Log "[$Vserver] Or resynchronize your DR by running a [Resync -ForceRecreate] then a [ConfigureDR] step"
        }
    }else{
        Write-LogDebug "Client not ready for Migrate"
		Write-Log "[$Vserver] Migration canceled"
        clean_and_exit 1
    }
	clean_and_exit 0
}

if( $DeleteSource ) {
    $Run_Mode="DeleteSrouce"
    Write-LogOnly "SVMTOOL DeleteSource"
    # Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$PrimaryClusterName=$NcPrimaryCtrl.Name
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$SecondaryClusterName=$NcSecondaryCtrl.Name
    $SourceVserver=Get-NcVserver -Name $Vserver -Controller $NcPrimaryCtrl -ErrorVariable ErrorVar
    if($? -ne $True){Write-LogError "ERROR : SVM [$Vserver] does not exist on [$PrimaryClusterName]";clean_and_exit 1}
    $SourceState=$SourceVserver.State

    $DestVserver=Get-NcVserver -Name $VserverDR -Controller $NcSecondaryCtrl -ErrorVariable ErrorVar
    if($? -ne $True){Write-LogError "ERROR : SVM [$Vserver] does not exist on [$SecondaryClusterName]";clean_and_exit 1}
    $DestState=$DestVserver.State
    if($SourceState -ne "stopped" -or $DestState -ne "running"){
        Write-Log "ERROR : SVM [$Vserver] not correctly migrated to destination [$SecondaryClusterName]. Failed to delete on source"
        clean_and_exit 1
    }else{
        Write-Warning "[$Vserver] Delete Source SVM cannot be interrupted or rolled back"
        $ASK_WAIT=Read-HostOptions -question "Do you want to completely delete [$Vserver] on [$PrimaryClusterName] ?" -options "y/n" -default "y"
        if($ASK_WAIT -eq 'y'){
            if ( ( $ret=remove_snapmirror_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR) -ne $True ) {
			    Write-LogError "ERROR: remove_snapmirror_dr failed" 
			    clean_and_exit 1
		    }

            if ( ( remove_vserver_peer -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne $True ) {
		        Write-LogError "ERROR: remove_vserver_peer failed" 
		        return $false
	        }

		    Write-Log "[$VserverDR] Renamed to [$Vserver]"
		    Write-LogDebug "Rename-NcVserver -Name $VserverDR -NewName $Vserver -Controller $NcSecondaryCtrl"
		    $out=Rename-NcVserver -Name $VserverDR -NewName $Vserver -Controller $NcSecondaryCtrl  -ErrorVariable ErrorVar
		    if ( $? -ne $True ) { throw "ERROR: Rename-NcVserver failed [$ErrorVar]"} 
		    Write-Log "[$Vserver] will be deleted on cluster [$PrimaryClusterName]"
		    if ( ( $ret=remove_vserver_source -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -eq $False ) {
		        Write-LogError "ERROR: remove_vserver_dr: Unable to remove vserver [$VserverDR]" 
		        clean_and_exit 1
	        }
            Write-Log "[$Vserver] completely deleted on [$PrimaryClusterName]"
            clean_and_exit 0
        }else{
            Write-Log "[$Vserver] will not be deleted on [$PrimaryClusterName]"
            clean_and_exit 0
        }
    }
}

if ( $UpdateDR ) {
    $Run_Mode="UpdateDR"
	Write-LogOnly "SVMTOOL UpdateDR"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
	# if ( ( $ret=analyse_junction_path -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne $True ) {
    	# Write-LogError "ERROR: analyse_junction_path" 
		# clean_and_exit 1
	# }
	if ( ( $ret=create_update_cron_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl ) -ne $True ) {
		Write-LogError "ERROR: create_update_cron_dr"
	}
	if ( ( $ret=create_update_snap_policy_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR) -ne $True ) {
		Write-LogError "ERROR: create_update_snap_policy_dr"
	}

	if ( ( $ret=check_cluster_peer -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl ) -ne $True ) {
		Write-LogError "ERROR: check_cluster_peer failed"
		clean_and_exit 1
	}

	if ( ($ret=update_vserver_dr -myDataAggr $DataAggr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR -DDR ($DRfromDR.IsPresent) -aggrMatchRegEx $AggrMatchRegex -nodeMatchRegEx $NodeMatchRegex) -ne $True ) {
		Write-LogError "ERROR: update_vserver_dr failed" 
			clean_and_exit 1

	}

    if ( ( $ret=update_CIFS_server_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne $True ) {
        Write-Warning "Some CIFS options has not been set on [$VserverDR]"
    }
    #if ( ( update_cifs_usergroup -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR) -ne $True ) {
    #    Write-LogError "ERROR: update_cifs_usergroup failed"
	#	clean_and_exit 1
    #}
  	if ( ( $ret=svmdr_db_switch_datafiles -myController $NcPrimaryCtrl -myVserver $Vserver ) -eq $false ) {
        	Write-LogError "ERROR: Failed to switch SVMTOOL_DB datafiles" 
        	clean_and_exit 1
  	}
	if ( ( $ret=save_vol_options_to_voldb -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne $True ) {
		Write-LogError "ERROR: save_vol_options_to_voldb failed"
		clean_and_exit 1
	}
	if ( $AllowQuotaDR -eq "True" ) {
		Write-Log "[$VserverDR] Save quota policy rules to SVMTOOL_DB [$SVMTOOL_DB]" -firstValueIsSpecial
		if ( ( $ret=save_quota_rules_to_quotadb -myPrimaryController $NcPrimaryCtrl -myPrimaryVserver $Vserver -mySecondaryController $NcSecondaryCtrl -mySecondaryVserver $VserverDR ) -ne $True ) {
 			Write-LogError "ERROR: save_quota_rules_to_quotadb failed"
 			clean_and_exit 1
		}
	}
	clean_and_exit 0
}

if ( $CloneDR ) {
	$Run_Mode="CloneDR"
	Write-LogOnly "SVMTOOL CloneDR"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$CloneVserverDR=$($VserverDR+"_clone")
	$ListCloneVserver=Get-NcVserver -Query @{VserverName=$($CloneVserverDR+"*")} -Controller $NcSecondaryCtrl -ErrorVariable ErrorVar
    if ( $? -ne $True ) { $Return = $False ; throw "ERROR: Get-NcVserver failed [$ErrorVar]" }
    if($ListCloneVserver -eq $null){
		$CloneVserverDR+=".0"	
	}else{
		$ListCloneVserver=$ListCloneVserver | Sort-Object
		$newNumber=([Int]($ListCloneVserver[-1].Vserver.split(".")[-1]))+1
		$CloneVserverDR+=$("."+$newNumber)	
	}
	Write-Log "Create Clone SVM [$CloneVserverDR]"
	if ( ( $ret=create_clonevserver_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $CloneVserverDR)[-1] -ne $True ) {
		Write-LogDebug "ERROR: create_vserver_dr failed"
		clean_and_exit 1
	}
	if ( ( enable_network_protocol_vserver_dr -myController $NcSecondaryCtrl -myVserver $CloneVserverDR ) -ne $True ) {
		Write-LogError "ERROR: Unable to Start all NetWork Protocols in Vserver $mySecondaryVserver $myController"
		$Return = $False
	}
	# if ( ($ret=restore_quota -myController $NcSecondaryCtrl -myVserver $SourceVserver) -ne $True){
	# 	Write-LogDebug "restore_quota return False [$ret]"
	# 	#return $False
	# }
    if ( ( $ret=set_vol_options_from_voldb -myController $NcSecondaryCtrl -myVserver $VserverDR -CloneDR $CloneVserverDR) -ne $True ) {
		Write-LogError "ERROR: set_vol_options_from_voldb failed"
	}
	if ( $AllowQuotaDR -eq "True" ) {
		if ( ( $ret=create_quota_rules_from_quotadb -myController $NcSecondaryCtrl -myVserver $VserverDR -CloneDR $CloneVserverDR) -ne $True ) {
			Write-LogError "ERROR: create_quota_rules_from_quotadb failed"
		}
	}
	clean_and_exit 0
}

if ( $SplitCloneDR ){
	$Run_Mode="SplitCloneDR"
	Write-LogOnly "SVMTOOL SplitCloneDR"
	# Connect to the Cluster
}

if ( $DeleteCloneDR ){
	$Run_Mode="DeleteCloneDR"
	Write-LogOnly "SVMTOOL DeleteCloneDR"
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        clean_and_exit 1
	}
	if($CloneName.length -gt 1){
		$CloneVserverList=$CloneName	
	}elseif ( ( $CloneVserverList=get_vserver_clone -DestinationVserver $VserverDR -mySecondaryController $NcSecondaryCtrl) -eq $null ){
		Write-Log "No Vserver Clone from [$VserverDR] found on Cluster [$SECONDARY_CLUSTER]" 
        clean_and_exit 0
	}
	foreach ($CloneVserver in $CloneVserverList){
		$ANS=Read-HostOptions "Are you sure you want to delete Vserver Clone [$CloneVserver] from [$SECONDARY_CLUSTER] ?" "y/n"
		if ( $ANS -eq 'y' ) {
			if ( ( $ret=remove_vserver_clone_dr -mySecondaryController $NcSecondaryCtrl -mySecondaryVserver $CloneVserver ) -eq $False ) {
				Write-LogError "ERROR: remove_vserver_dr: Unable to remove Vserver [$VserverDR]" 
				clean_and_exit 1
			}	
		}
	}
	clean_and_exit 0
}

if ( $ActivateDR ) {
    $Run_Mode="ActivateDR"
	Write-LogOnly "SVMTOOL ActivateDR"
	# Connect to the Cluster
	if ( $ForceActivate -eq $True ) {
		Write-Log "Force Activate vserver $VserverDR"
	} 
    else 
    {

		$ANS=Read-HostOptions -question "Do you want to disable the primary vserver [$Vserver] from [$PRIMARY_CLUSTER] ?" -options "y/n" -default "y"

		if ( $ANS -eq 'y' ) {
			$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
			$tmp_str=$MyCred.UserName
			Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
			Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
			if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
				Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]"
			} else {
				if ( ( $ret=disable_network_protocol_vserver_dr -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne $True ) {
					Write-LogError "ERROR: Failed to desactivate all Network Services for $Vserver"
				}
			}
		}
	}

	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}

	if ( ( $ret=activate_vserver_dr -myController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne $True ) {
		Write-LogError "ERROR: activate_vserver_dr failed"
		clean_and_exit 1
	}
	# if ( ( update_CIFS_server_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne $True ) {
        # Write-Warning "Some CIFS options has not been set on [$VserverDR]"
    # }
    # if ( ( update_cifs_usergroup -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR) -ne $True ) {
        # Write-LogError "ERROR: update_cifs_usergroup failed"
		# clean_and_exit 1
    # }
    # if ( ( create_update_localuser_dr -myPrimaryController $myPrimaryController -mySecondaryController $mySecondaryController -myPrimaryVserver $myPrimaryVserver -mySecondaryVserver $mySecondaryVserver) -ne $True ) { 
        # Write-LogError "ERROR: Failed to create all user"
        # $Return = $True 
    # }
	if ( ( $ret=set_vol_options_from_voldb -myController $NcSecondaryCtrl -myVserver $VserverDR ) -ne $True ) {
		Write-LogError "ERROR: set_vol_options_from_voldb failed"
	}
    #if ( ( $ret=set_shareacl_options_from_shareacldb -myController $NcSecondaryCtrl -myVserver $VserverDR ) -ne $True ) {
	#	Write-LogError "ERROR: set_shareacl_options_from_shareacldb"
	#}
	if ( $AllowQuotaDR -eq "True" ) {
		if ( ( $ret=create_quota_rules_from_quotadb -myController $NcSecondaryCtrl -myVserver $VserverDR  ) -ne $True ) {
			Write-LogError "ERROR: create_quota_rules_from_quotadb failed"
		}
	}
	clean_and_exit 0
}

if ( $CreateQuotaDR ) {
    $Run_Mode="CreateQuotaDR"
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}

	if ( ( $ret=create_quota_rules_from_quotadb -myController $NcSecondaryCtrl -myVserver $VserverDR  ) -ne $True ) {
		Write-LogError "ERROR: create_quota_rules_from_quotadb failed"
		clean_and_exit 1
	}
	clean_and_exit 0
}

if ( $ReCreateQuota ) {
    $Run_Mode="ReCreateQuota"
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPriamaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}

	if ( ( $ret=create_quota_rules_from_quotadb -myController $NcPrimaryCtrl -myVserver $Vserver  ) -ne $True ) {
		Write-LogError "ERROR: create_quota_rules_from_quotadb failed"
		clean_and_exit 1
	}
	clean_and_exit 0
}

if ( $ReActivate ) {
    $Run_Mode="ReActivate"
	Write-LogOnly "SVMTOOL ReActivate"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
		clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
		clean_and_exit 1
	}
	if ( ( $ret=check_cluster_peer -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl ) -ne $True ) { 
		Write-LogError "ERROR: check_cluster_peer failed" 
		clean_and_exit 1
	}
	if ( ( $ret=disable_network_protocol_vserver_dr -myController $NcSecondaryCtrl -myVserver $VserverDR ) -ne $True ) { 
		Write-LogError "ERROR: disable_network_protocol_vserver_dr failed" 
		clean_and_exit 1
	}
	if ( ( $ret=restart_vserver_dr -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne  $True ) {
		Write-LogError "ERROR: restart_vserver_dr failed" 
		clean_and_exit 1
	}	
	if ( ( $ret=activate_vserver_dr -myController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver ) -ne  $True ) {
		Write-LogError "ERROR: activate_vserver_dr failed" 
		clean_and_exit 1
	}
	if ( ( $ret=resync_vserver_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne  $True ) { 
		Write-LogError "ERROR: resync_vserver_dr failed" 
		clean_and_exit 1
	}

	if ( ( $ret=check_snapmirror_broken_dr -myPrimaryController $NcSecondary -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver ) -ne $True ) { 
		Write-LogError "ERROR: Failed snapmirror relations bad status unable to clean" 
		clean_and_exit 1
	}

	if ( ( $ret=remove_snapmirror_dr -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver	 ) -ne $True ) { 
		Write-LogError "ERROR: remove_snapmirror_dr failed" 
		clean_and_exit 1
	}
	if ( ( $ret=set_vol_options_from_voldb -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne $True ) {
		Write-LogError "ERROR: set_vol_options_from_voldb failed"
	}
    #if ( ( $ret=set_shareacl_options_from_shareacldb -myController $NcPrimaryCtrl -myVserver $Vserver ) -ne $True ) {
	#	Write-LogError "ERROR: set_shareacl_options_from_shareacldb"
	#}
	if ( $AllowQuotaDR -eq "True" ) {
		if ( ( $ret=create_quota_rules_from_quotadb -myController $NcPrimaryCtrl -myVserver $Vserver  ) -ne $True ) {
			Write-LogError "ERROR: create_quota_rules_from_quotadb failed"
		}
	}
	clean_and_exit 0
}

if ( $CleanReverse ) {
    $Run_Mode="CleanReverse"
	Write-LogOnly "SVMTOOL CleanReverse"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
		clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
		clean_and_exit 1
	}
	if ( ( $ret=check_snapmirror_broken_dr -myPrimaryController $NcSecondary -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver ) -ne $True ) { 
		Write-LogError "ERROR: Failed snapmirror relations bad status unable to clean" 
		clean_and_exit 1
	}
	if ( ( $ret=remove_snapmirror_dr -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver	 ) -ne $True ) { 
		Write-LogError "ERROR: remove_snapmirror_dr failed" 
		clean_and_exit 1
	}
	clean_and_exit 0
}

if ( $Resync ) {
    $Run_Mode="Resync"
	Write-LogOnly "SVMTOOL Resync"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	$ANS = Read-HostOptions -question "Do you want to erase data on vserver [$VserverDR] [$SECONDARY_CLUSTER] with data available on [$Vserver] [$PRIMARY_CLUSTER] ?" -options "y/n" -default "y"

	if ( $ANS -ne 'y' ) {
		clean_and_exit 0
	}
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred  -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
	if ( ( $ret=resync_vserver_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR ) -ne $True ) {
		Write-LogError "ERROR: Resync error"
		clean_and_exit 1
	}
	clean_and_exit 0 
}

if ( $ResyncReverse ) {
    $Run_Mode="ResyncReverse"
	Write-LogOnly "SVMTOOL ResyncReverse"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName

	$ANS = Read-HostOptions -question "Do you want to erase data on vserver [$Vserver] [$PRIMARY_CLUSTER] ?" -options "y/n" -default "y"
	if ( $ANS -ne 'y' ) {
		clean_and_exit 0
	}

	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
	if ( ( $ret=resync_reverse_vserver_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR) -ne $True ) {
		Write-LogError "ERROR: Resync Reverse error"
		clean_and_exit 1
	}
	clean_and_exit 0 
}

if ( $UpdateReverse ) {
    $Global:NonInteractive=$true
    $Run_Mode="UpdateReverse"
	Write-LogOnly "SVMTOOL UpdateReverse"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
	# if ( ( $ret=analyse_junction_path -myController $NcPrimaryCtrl -myVserver $Vserver) -ne $True ) {
    	# Write-LogError "ERROR: analyse_junction_path" 
		# clean_and_exit 1
	# }
	if ( ( $ret=check_cluster_peer -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl ) -ne $True ) {
		Write-LogError "ERROR: check_cluster_peer" 
		clean_and_exit 1
	}

	if ( ( $ret=update_vserver_dr -myDataAggr $DataAggr -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver -DDR ($DRfromDR.IsPresent) -aggrMatchRegEx $AggrMatchRegex -nodeMatchRegEx $NodeMatchRegex) -ne  $True ) { 
		Write-LogError "ERROR: update_vserver_dr" 
		clean_and_exit 1 

	}

    if ( ( $ret=update_CIFS_server_dr -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver ) -ne $True ) {
        Write-Warning "Some CIFS options has not been set on [$Vserver]"
    }
    #if ( ( update_cifs_usergroup -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver ) -ne $True ) {
    #    Write-LogError "ERROR: update_cifs_usergroup failed"
	#	clean_and_exit 1
    #}
  	if ( ( $ret=svmdr_db_switch_datafiles -myController $NcSecondaryCtrl -myVserver $VserverDR ) -eq $false ) {
        	Write-LogError "ERROR: Failed to switch SVMTOOL_DB datafiles" 
        	clean_and_exit 1
  	}
	if ( ( $ret=save_vol_options_to_voldb -myController $NcSecondaryCtrl -myVserver $VserverDR ) -ne $True ) {
		Write-LogError "ERROR: save_vol_options_to_voldb failed"
		clean_and_exit 1
	}
    if ( ( $ret=create_update_cron_dr -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl ) -ne $True ) {
		Write-LogError "ERROR: create_update_cron_dr"
	}
	if ( ( $ret=create_update_snap_policy_dr -myPrimaryController $NcSecondaryCtrl -mySecondaryController $NcPrimaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver) -ne $True ) {
		Write-LogError "ERROR: create_update_snap_policy_dr"
	}
	if ( $AllowQuotaDR -eq "True" ) {
		Write-Log "[$VserverDR] Save quota policy rules to SVMTOOL_DB [$SVMTOOL_DB]" -firstValueIsSpecial
		if ( ( $ret=save_quota_rules_to_quotadb -myPrimaryController $NcSecondaryCtrl -myPrimaryVserver $VserverDR -mySecondaryController $NcPrimaryCtrl -mySecondaryVserver $Vserver ) -ne $True ) {
 			Write-LogError "ERROR: save_quota_rules_to_quotadb failed"
 			clean_and_exit 1
		}
	}
	<# if ( $MirrorSchedule ) {
		Write-LogDebug "Flag MirrorSchedule"
	} else {
		clean_and_exit 0
	} #>
	clean_and_exit 0
}

if ( $MirrorSchedule ) {
    $Run_Mode="MirrorSchedule"
    Write-LogOnly "SVMTOOL MirrorSchedule"
    # Connect to the Cluster
    $myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
    $tmp_str=$MyCred.UserName
    Write-LogDebug "Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
    Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
    if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
        Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        clean_and_exit 1
    }
    $myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
    Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
    if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
        Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        clean_and_exit 1
    }
    if ( ( $ret=set_snapmirror_schedule_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $Vserver -mySecondaryVserver $VserverDR -mySchedule $MirrorSchedule ) -ne $True ) {
        Write-LogError "ERROR: set_snapmirror_schedule_dr error"
        clean_and_exit 1
    }
    clean_and_exit 0
}

if ( $MirrorScheduleReverse ) {
    $Run_Mode="MirrorScheduleReverse"
    Write-LogOnly "SVMTOOL MirrorScheduleReverse"
    # Connect to the Cluster
    $myCred=get_local_cDotcred ($SECONDARY_CLUSTER) 
    $tmp_str=$MyCred.UserName
    Write-LogDebug "Connect to cluster [$SECONDARY_CLUSTER] with login [$tmp_str]"
    Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
    if ( ( $NcPrimaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
        Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        clean_and_exit 1
    }
    $myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
    Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
    if ( ( $NcSecondaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
        Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        clean_and_exit 1
    }
    if ( ( $ret=set_snapmirror_schedule_dr -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl -myPrimaryVserver $VserverDR -mySecondaryVserver $Vserver -mySchedule $MirrorScheduleReverse ) -ne $True ) {
        Write-LogError "ERROR: set_snapmirror_schedule_dr error"
        clean_and_exit 1
    }
    clean_and_exit 0
}

if ( $InternalTest ) {
	Write-LogOnly "SVM InternalTest"
	# Connect to the Cluster
	$myCred=get_local_cDotcred ($PRIMARY_CLUSTER) 
	$tmp_str=$MyCred.UserName
	Write-Log "[test] Connect to cluster [$PRIMARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcPrimaryCtrl =  connect_cluster $PRIMARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$PRIMARY_CLUSTER]" 
        	clean_and_exit 1
	}
	$myCred=get_local_cDotcred ($SECONDARY_CLUSTER)
    $tmp_str=$myCred.Username
    Write-Log "[test] Connect to cluster [$SECONDARY_CLUSTER] with login [$tmp_str]"
	Write-LogDebug "connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout"
	if ( ( $NcSecondaryCtrl =  connect_cluster $SECONDARY_CLUSTER -myCred $MyCred -myTimeout $Timeout ) -eq $False ) {
		Write-LogError "ERROR: Unable to Connect to NcController [$SECONDARY_CLUSTER]" 
        	clean_and_exit 1
	}
    Write-Log "[test] Cluster Peer from cluster [$NcPrimaryCtrl] to cluster [$NcSecondaryCtrl]" 
	if ( ( $ret=check_cluster_peer -myPrimaryController $NcPrimaryCtrl -mySecondaryController $NcSecondaryCtrl) -ne $True ) {
		Write-LogError "ERROR: check_cluster_peer failed"
		clean_and_exit 1
	}
    Write-Log "Tests completed successfully" -color green
	# _ADD TEST
	# _ADD TEST
	clean_and_exit 0 
}

Write-LogError "ERROR: No options selected: Use Help Options for more information" 
clean_and_exit 1
