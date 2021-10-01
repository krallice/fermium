resource "azurerm_api_management" "apim" {
  name                       = "ferm-apim-00"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  publisher_email            = "srozanc@macquariecloudservices.com"
  publisher_name             = "sjr-fermium"
  sku_name                   = "Developer_1"
  client_certificate_enabled = false
  gateway_disabled           = false
  identity {
    type = "SystemAssigned"
  }
  protocols {
    enable_http2 = false
  }

  security {
    enable_backend_ssl30                                = false
    enable_backend_tls10                                = false
    enable_backend_tls11                                = false
    enable_frontend_ssl30                               = false
    enable_frontend_tls10                               = false
    enable_frontend_tls11                               = false
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = false
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = false
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = false
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = false
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = false
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = false
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = false
    triple_des_ciphers_enabled                          = false
  }

  sign_in {
    enabled = false
  }

  sign_up {
    enabled = true

    terms_of_service {
      consent_required = false
      enabled          = false
    }
  }

  timeouts {}
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

resource "azurerm_api_management_product" "fermium-product" {
  product_id            = "fermium-product"
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = azurerm_resource_group.rg.name
  display_name          = "fermium-product"
  subscription_required = false
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_api" "fermium_v2_rev2" {
  name                  = "fermium-v2"
  resource_group_name   = azurerm_resource_group.rg.name
  api_management_name   = azurerm_api_management.apim.name
  version               = "v2"
  revision              = "2"
  display_name          = "fermium"
  path                  = "fermium"
  subscription_required = false
  soap_pass_through     = false
  protocols = [
    "http",
  ]
  import {
    content_format = "openapi+json-link"
    content_value  = "https://raw.githubusercontent.com/krallice/fermium/master/api/fermium_v2_rev2.json"
  }
}

resource "azurerm_api_management_api_version_set" "fermium_v2" {
  name                = "6151ac05e139cd62d9f6c772"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "fermium"
  versioning_scheme   = "Segment"
}
