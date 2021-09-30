resource "azurerm_api_management" "apim" {
  name                = "ferm-apim-00"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_email     = "srozanc@macquariecloudservices.com"
  publisher_name      = "sjr-fermium"
  sku_name            = "Developer_1"
  identity {
	  type 		= "SystemAssigned"
        }
}

resource "azurerm_api_management_backend" "prod-ferm-vm-00" {
  name                = "prod-ferm-vm-00"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  protocol            = "http"
  url                 = "http://prod-ferm-vm-00.noclab.com.au:80/"

  credentials {
    certificate = []
    header      = {}
    query       = {}
  }

  tls {
    validate_certificate_chain = false
    validate_certificate_name  = false
  }
}
