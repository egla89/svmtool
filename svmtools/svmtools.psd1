﻿#
# Module manifest for module 'svmtools'
#
# Generated by: Olivier MASSON
#
# Generated on: 2018-06-07
#
# Update by : Olivier MASSON
# Updated on : 2019-11-11
#
# Version Control :
#   1.0.4 : Initial version
#   1.0.5 : Bugfixes and typos
#   1.0.6 : Added color coding and advanced prompting
#   1.0.7 : Improved behaviour in case SVM has no LIF nor data volumes
#   1.0.8 : Add ForceUpdateSnapPolicy to not update snapshot policy on destination volumes by default
#   1.0.9 : Add Log4Net, bugfixes, noninteractive mode, ...
#   1.1.0 : Add FabricPool support on destination, bugfixes
#   1.1.1 : Fix Symlink, Fix restore quota, Add DefaultLDAPCredentials
#   1.1.2 : Completely rewrite ActivateDR and ReActivate, to improve behaviour and automate the switchover
#           Backup LIF/CIFS and Cluster informations to perform automated ActivateDR and ReActivate
#           add test_primary_alive to automate ActivateDR's behaviour
#           Improve Retore to original place for cluster/vserver
#           Fix cifssecurity sync
#   1.1.3 : Add -Raw to all Get-Content before beeing converted to JSON to fix issue with some special char
#           Fix Vscan configuration sync
#           improve CIFS shares creation in SelectVolume mode, where CIFS shares not hosted on destination volume, will be deleted on destination vserver
#   1.1.4 : Fix restarting services during ReActivate
#           Fix mount_voldr in SelectVolume mode
#           Modify Create/update Vscan and Fpolicy to only exclude in NonInteractive mode the update of Vscan Scanner Pool and Fpolicy External Engine
#           Fix Create/update Fpolicy Scope
#           Fix Backup and Restore Fpolicy
#   1.1.5 : Fix creation of firewall service "portmap" only if destination is running ONTAP 9.5 or more
#           Manage additionnal network static route
#   1.1.6 : Add support of Volume Encryption on destination
#   1.1.7 : Modify create_update_CIFS_shares_dr behaviour on c$, admin$ or ipc$ non-data special share
#   1.1.8 : Correct import_instance_svmdr to generate LIF and CIFS details JSON files during import
#   1.1.9 : Modify behavior during UpdateDR. Now the script no longer checks for differences or absence of LIF or route to the destination during an UpdateDR (or Update-SvmDr). 
#           This is in order to preserve any differences in gateway or other between the Primary and the Secondary.
#           If you need to modify/create your LIFs or Routes configuration on the Secondary, you must now do so only with a ConfigureDR (or New-SvmDr)
#   1.2.0 : Added NoSnapmirrorUpdate and NoSnapmirrorWait flags for updateDR (mirko)
#           Added MirrorSchedule & XDPPolicy for UpdateDR & ConfigureDR (default remains hourly schedule)
#           Use "none" to omit the schedule
#   1.2.1 : Fix Change of XDPPolicy during ConfigureDR (New-SvmDR) or UpdateDR (Update-SvmDr)
#   1.2.2 : Added custom vlan & ou to join in AD
#   1.2.3 : Fix check if CIFS server is running
#   1.2.4 : Fix gateway creation
#           Add support for Data replication with Sync and StrictSync Policy
#           Automatic conversion of Async to Sync relationships and vice versa
#           Introduce RestoreObject to allow restores only part of SVM configuration: LIFs, Volumes, Exports, Shares, Quotas (still is progress)
#   1.2.5 : Fix wait_snapmirror_dr  
#   1.2.6 : Introduce ForceCloneOriginal option
#           Fix for XDPPolicy
#           Change replication of DnsDomain for LIF, now DnsDomain is only updated on Destination with Migrate, ActivateDR, CloneVserverDR with ForceCloneOriginal, ReActivate
#   1.2.7 : Correct Restore_Object Shares
#         : Add SnapmirrorType option to force DP relationship instead of XDP
#   1.2.8 : Modify NonInteractive Mode for ConfigureDR opereations after 'Wait SnapMirror End' 
#           Modify NonInteractive Mode for CloneDR with ForceCloneOriginal option
#   1.2.9 : Add PreserveIdentity Mode
@{

    # Script module or binary module file associated with this manifest.
    RootModule        = '.\svmtools.psm1'

    # Version number of this module.
    ModuleVersion     = '1.2.9'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '4c1a11a6-b6b9-4a1a-aa87-1c5976148ec7'

    # Author of this module
    Author            = 'Olivier MASSON'

    # Company or vendor of this module
    CompanyName       = 'NetApp'

    # Copyright statement for this module
    Copyright         = '(c) 2019 Netapp. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'This module contains several tools (cmdlet) to work with SVM in order to perform SVMDR with Metrocluster on source or destination, Backup and Restore of configuration, etc...'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '3.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = '*'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = '*'

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = '*'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    FileList          = @('log4net.dll')

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/oliviermasson/svmtool'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI       = 'https://github.com/oliviermasson/svmtool'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

