locals {


  resource_providers = [
    "Microsoft.ApiSecurity",
    "Microsoft.App",
    "Microsoft.AppAssessment",
    "Microsoft.AppComplianceAutomation"
  ]
  /*[
    "Microsoft.Advisor",
    "Microsoft.MarketplaceNotifications",
    "Microsoft.Security",
    "Microsoft.GuestConfiguration",
    "Microsoft.PolicyInsights",
    "Astronomer.Astro",
    "Dynatrace.Observability",
    "GitHub.Network",
    "Microsoft.AAD",
    "Microsoft.AadCustomSecurityAttributesDiagnosticSettings",
    "microsoft.aadiam",
    "Microsoft.Addons",
    "Microsoft.ADHybridHealthService",
    "Microsoft.AgFoodPlatform",
    "Microsoft.AksHybrid",
    "Microsoft.AlertsManagement",
    "Microsoft.AnalysisServices",
    "Microsoft.AnyBuild",
    "Microsoft.ApiCenter",
    "Microsoft.ApiManagement",
    "Microsoft.ApiSecurity",
    "Microsoft.App",
    "Microsoft.AppAssessment",
    "Microsoft.AppComplianceAutomation",
    "Microsoft.AppConfiguration",
    "Microsoft.AppPlatform",
    "Microsoft.AppSecurity",
    "Microsoft.ArcNetworking",
    "Microsoft.Attestation",
    "Microsoft.Authorization",
    "Microsoft.Automanage",
    "Microsoft.Automation",
    "Microsoft.AutonomousDevelopmentPlatform",
    "Microsoft.AVS",
    "Microsoft.AwsConnector",
    "Microsoft.AzureActiveDirectory",
    "Microsoft.AzureArcData",
    "Microsoft.AzureCIS",
    "Microsoft.AzureLargeInstance",
    "Microsoft.AzurePercept",
    "Microsoft.AzurePlaywrightService",
    "Microsoft.AzureScan",
    "Microsoft.AzureSphere",
    "Microsoft.AzureStack",
    "Microsoft.AzureStackHCI",
    "Microsoft.BackupSolutions",
    "Microsoft.BareMetalInfrastructure",
    "Microsoft.Batch",
    "Microsoft.Billing",
    "Microsoft.BillingBenefits",
    "Microsoft.Bing",
    "Microsoft.BlockchainTokens",
    "Microsoft.Blueprint",
    "Microsoft.BotService",
    "Microsoft.Cache",
    "Microsoft.Capacity",
    "Microsoft.Carbon",
    "Microsoft.Cdn",
    "Microsoft.CertificateRegistration",
    "Microsoft.ChangeAnalysis",
    "Microsoft.Chaos",
    "Microsoft.ClassicCompute",
    "Microsoft.ClassicInfrastructureMigrate",
    "Microsoft.ClassicNetwork",
    "Microsoft.ClassicStorage",
    "Microsoft.ClassicSubscription",
    "Microsoft.CleanRoom",
    "Microsoft.CloudHealth",
    "Microsoft.CloudShell",
    "Microsoft.CloudTest",
    "Microsoft.CodeSigning",
    "Microsoft.CognitiveServices",
    "Microsoft.Commerce",
    "Microsoft.Communication",
    "Microsoft.Community",
    "Microsoft.Compute",
    "Microsoft.ComputeSchedule",
    "Microsoft.ConfidentialLedger",
    "Microsoft.Confluent",
    "Microsoft.ConnectedCache",
    "Microsoft.ConnectedCredentials",
    "microsoft.connectedopenstack",
    "Microsoft.ConnectedVehicle",
    "Microsoft.ConnectedVMwarevSphere",
    "Microsoft.Consumption",
    "Microsoft.ContainerInstance",
    "Microsoft.ContainerRegistry",
    "Microsoft.ContainerService",
    "Microsoft.CostManagement",
    "Microsoft.CostManagementExports",
    "Microsoft.CustomerLockbox",
    "Microsoft.CustomProviders",
    "Microsoft.D365CustomerInsights",
    "Microsoft.Dashboard",
    "Microsoft.DatabaseFleetManager",
    "Microsoft.DatabaseWatcher",
    "Microsoft.DataBox",
    "Microsoft.DataBoxEdge",
    "Microsoft.Databricks",
    "Microsoft.DataCatalog",
    "Microsoft.Datadog",
    "Microsoft.DataFactory",
    "Microsoft.DataLakeAnalytics",
    "Microsoft.DataLakeStore",
    "Microsoft.DataMigration",
    "Microsoft.DataProtection",
    "Microsoft.DataReplication",
    "Microsoft.DataShare",
    "Microsoft.DBforMariaDB",
    "Microsoft.DBforMySQL",
    "Microsoft.DBforPostgreSQL",
    "Microsoft.DelegatedNetwork",
    "Microsoft.DeploymentManager",
    "Microsoft.DesktopVirtualization",
    "Microsoft.DevAI",
    "Microsoft.DevCenter",
    "Microsoft.DevHub",
    "Microsoft.DeviceRegistry",
    "Microsoft.Devices",
    "Microsoft.DeviceUpdate",
    "Microsoft.DevOpsInfrastructure",
    "Microsoft.DevTestLab",
    "Microsoft.DigitalTwins",
    "Microsoft.DocumentDB",
    "Microsoft.DomainRegistration",
    "Microsoft.Easm",
    "Microsoft.EdgeManagement",
    "Microsoft.EdgeMarketplace",
    "Microsoft.EdgeOrder",
    "Microsoft.EdgeOrderPartner",
    "Microsoft.Elastic",
    "Microsoft.ElasticSan",
    "Microsoft.EnterpriseSupport",
    "Microsoft.EntitlementManagement",
    "Microsoft.EventGrid",
    "Microsoft.EventHub",
    "Microsoft.Experimentation",
    "Microsoft.ExtendedLocation",
    "Microsoft.Fabric",
    "Microsoft.Falcon",
    "Microsoft.Features",
    "Microsoft.FluidRelay",
    "Microsoft.GraphServices",
    "Microsoft.HanaOnAzure",
    "Microsoft.HardwareSecurityModules",
    "Microsoft.HDInsight",
    "Microsoft.HealthBot",
    "Microsoft.HealthcareApis",
    "Microsoft.HealthDataAIServices",
    "Microsoft.HealthModel",
    "Microsoft.Help",
    "Microsoft.HybridCloud",
    "Microsoft.HybridCompute",
    "Microsoft.HybridConnectivity",
    "Microsoft.HybridContainerService",
    "Microsoft.HybridNetwork",
    "Microsoft.Impact",
    "microsoft.insights",
    "Microsoft.IntegrationSpaces",
    "Microsoft.IoTCentral",
    "Microsoft.IoTFirmwareDefense",
    "Microsoft.IoTOperationsDataProcessor",
    "Microsoft.IoTOperationsMQ",
    "Microsoft.IoTOperationsOrchestrator",
    "Microsoft.IoTSecurity",
    "Microsoft.KeyVault",
    "Microsoft.Kubernetes",
    "Microsoft.KubernetesConfiguration",
    "Microsoft.KubernetesRuntime",
    "Microsoft.Kusto",
    "Microsoft.LabServices",
    "Microsoft.LoadTestService",
    "Microsoft.Logic",
    "Microsoft.Logz",
    "Microsoft.MachineLearning",
    "Microsoft.MachineLearningServices",
    "Microsoft.Maintenance",
    "Microsoft.ManagedIdentity",
    "Microsoft.ManagedNetworkFabric",
    "Microsoft.ManagedServices",
    "Microsoft.Management",
    "Microsoft.ManufacturingPlatform",
    "Microsoft.Maps",
    "Microsoft.Marketplace",
    "Microsoft.MarketplaceOrdering",
    "Microsoft.Media",
    "Microsoft.Metaverse",
    "Microsoft.Migrate",
    "Microsoft.Mission",
    "Microsoft.MixedReality",
    "Microsoft.MobileNetwork",
    "Microsoft.MobilePacketCore",
    "Microsoft.ModSimWorkbench",
    "Microsoft.Monitor",
    "Microsoft.MySQLDiscovery",
    "Microsoft.NetApp",
    "Microsoft.Network",
    "Microsoft.NetworkAnalytics",
    "Microsoft.NetworkCloud",
    "Microsoft.NetworkFunction",
    "Microsoft.NotificationHubs",
    "Microsoft.Nutanix",
    "Microsoft.ObjectStore",
    "Microsoft.OffAzure",
    "Microsoft.OffAzureSpringBoot",
    "Microsoft.OpenEnergyPlatform",
    "Microsoft.OpenLogisticsPlatform",
    "Microsoft.OperationalInsights",
    "Microsoft.OperationsManagement",
    "Microsoft.OperatorVoicemail",
    "Microsoft.OracleDiscovery",
    "Microsoft.Orbital",
    "Microsoft.PartnerManagedConsumerRecurrence",
    "Microsoft.Peering",
    "Microsoft.Pki",
    "Microsoft.PlayFab",
    "Microsoft.Portal",
    "Microsoft.PowerBI",
    "Microsoft.PowerBIDedicated",
    "Microsoft.PowerPlatform",
    "Microsoft.ProfessionalService",
    "Microsoft.ProgrammableConnectivity",
    "Microsoft.ProviderHub",
    "Microsoft.Purview",
    "Microsoft.Quantum",
    "Microsoft.Quota",
    "Microsoft.RecommendationsService",
    "Microsoft.RecoveryServices",
    "Microsoft.RedHatOpenShift",
    "Microsoft.Relay",
    "Microsoft.ResourceConnector",
    "Microsoft.ResourceGraph",
    "Microsoft.ResourceHealth",
    "Microsoft.ResourceNotifications",
    "Microsoft.Resources",
    "Microsoft.SaaS",
    "Microsoft.SaaSHub",
    "Microsoft.Scom",
    "Microsoft.ScVmm",
    "Microsoft.Search",
    "Microsoft.SecurityDetonation",
    "Microsoft.SecurityDevOps",
    "Microsoft.SecurityInsights",
    "Microsoft.SerialConsole",
    "Microsoft.ServiceBus",
    "Microsoft.ServiceFabric",
    "Microsoft.ServiceFabricMesh",
    "Microsoft.ServiceLinker",
    "Microsoft.ServiceNetworking",
    "Microsoft.ServicesHub",
    "Microsoft.SignalRService",
    "Microsoft.Singularity",
    "Microsoft.SoftwarePlan",
    "Microsoft.Solutions",
    "Microsoft.Sovereign",
    "Microsoft.Sql",
    "Microsoft.SqlVirtualMachine",
    "Microsoft.StandbyPool",
    "Microsoft.Storage",
    "Microsoft.StorageActions",
    "Microsoft.StorageCache",
    "Microsoft.StorageMover",
    "Microsoft.StorageSync",
    "Microsoft.StorageTasks",
    "Microsoft.StreamAnalytics",
    "Microsoft.Subscription",
    "microsoft.support",
    "Microsoft.Synapse",
    "Microsoft.Syntex",
    "Microsoft.TestBase",
    "Microsoft.TimeSeriesInsights",
    "Microsoft.UsageBilling",
    "Microsoft.VideoIndexer",
    "Microsoft.VirtualMachineImages",
    "microsoft.visualstudio",
    "Microsoft.VMware",
    "Microsoft.VoiceServices",
    "Microsoft.VSOnline",
    "Microsoft.Web",
    "Microsoft.WindowsESU",
    "Microsoft.WindowsIoT",
    "Microsoft.WindowsPushNotificationServices",
    "Microsoft.WorkloadBuilder",
    "Microsoft.Workloads",
    "NewRelic.Observability",
    "NGINX.NGINXPLUS",
    "Oracle.Database",
    "PaloAltoNetworks.Cloudngfw",
    "Qumulo.Storage",
    "SolarWinds.Observability",
    "Wandisco.Fusion"
  ]*/
}