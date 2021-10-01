## Fermium API
# Version 3

resource "azurerm_api_management_api" "fermium_v3" {
  name                  = "fermium-v3"
  resource_group_name   = azurerm_resource_group.rg.name
  api_management_name   = azurerm_api_management.apim.name
  version               = "v3"
  revision              = "1"
  version_set_id        = azurerm_api_management_api_version_set.fermium_v2.id
  display_name          = "fermium"
  path                  = "fermium"
  subscription_required = false
  soap_pass_through     = false
  protocols = [
    "http",
  ]

  # Specify API through OpenAPI:
  import {
    content_format = "openapi+json-link"
    content_value  = "https://raw.githubusercontent.com/krallice/fermium/master/api/fermium_v2_rev2.json"
  }
}

# Global API Policy:
resource "azurerm_api_management_api_policy" "fermium_v3" {
  api_name            = azurerm_api_management_api.fermium_v3.name
  api_management_name = azurerm_api_management_api.fermium_v3.api_management_name
  resource_group_name = azurerm_api_management_api.fermium_v3.resource_group_name
  xml_link    	      = "https://github.com/krallice/fermium/blob/master/api/fermium_v3_global.xml"
}

# Specific Policies: 
resource "azurerm_api_management_api_operation_policy" "fermium_v3_get-elements-by-atomic" {
  api_name            = azurerm_api_management_api.fermium_v3.name
  api_management_name = azurerm_api_management_api.fermium_v3.api_management_name
  resource_group_name = azurerm_api_management_api.fermium_v3.resource_group_name
  operation_id        = "get-elements-by-atomic"
  xml_link 	      = "https://github.com/krallice/fermium/blob/master/api/fermium_v3_get-elements-by-atomic.xml"
}

resource "azurerm_api_management_api_operation_policy" "fermium_v3_get-elements" {
  api_name            = azurerm_api_management_api.fermium_v3.name
  api_management_name = azurerm_api_management_api.fermium_v3.api_management_name
  resource_group_name = azurerm_api_management_api.fermium_v3.resource_group_name
  operation_id        = "get-elements"
  xml_link 	      = "https://github.com/krallice/fermium/blob/master/api/fermium_v3_get-elements.xml"
}

# Alernate way of specifying API Operations through Terraform (will conflict with the openAPI import):

#resource "azurerm_api_management_api_operation" "fermium_v2_rev3_get-elements" {
#  api_name            = azurerm_api_management_api.fermium_v2_rev3.name
#  api_management_name = azurerm_api_management_api.fermium_v2_rev3.api_management_name
#  resource_group_name = azurerm_api_management_api.fermium_v2_rev3.resource_group_name
#  description         = "Get all elements keyed by atomic number, providing name"
#  operation_id        = "get-elements"
#  display_name        = "get-elements"
#  method              = "GET"
#  url_template        = "/elements"
#
#  request {
#  }
#
#  response {
#    status_code = 200
#
#    representation {
#      content_type = "application/json"
#      sample = jsonencode(
#        {
#          1 = {
#            atomicnumber = 1
#            elementname  = "hydrogen"
#          }
#          100 = {
#            atomicnumber = 100
#            elementname  = "fermium"
#          }
#        }
#      )
#    }
#  }
#}
#
#resource "azurerm_api_management_api_operation" "fermium_v2_rev3_get-elements-by-atomic" {
#  api_name            = azurerm_api_management_api.fermium_v2_rev3.name
#  api_management_name = azurerm_api_management_api.fermium_v2_rev3.api_management_name
#  resource_group_name = azurerm_api_management_api.fermium_v2_rev3.resource_group_name
#  description         = "Get all elements keyed by atomic number, providing name"
#  display_name        = "get-elements-by-atomic"
#  operation_id        = "get-elements-by-atomic"
#  method              = "GET"
#  url_template        = "/elements/{atomicnumber}"
#
#  request {
#  }
#
#  response {
#    status_code = 200
#
#    representation {
#      content_type = "application/json"
#      sample = jsonencode(
#        {
#          atomicnumber = 1
#          elementname  = "hydrogen"
#        }
#      )
#    }
#  }
#
#  template_parameter {
#    name     = "atomicnumber"
#    required = true
#    type     = "int"
#    values   = []
#  }
#
#  timeouts {}
#}
#
