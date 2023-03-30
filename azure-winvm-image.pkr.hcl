locals {
  timestamp = formatdate("YYYYMMDDhhmmss", timeadd(timestamp(), "9h"))
  image_version = formatdate("YYYY.MMDD.hhmm", timeadd(timestamp(), "9h"))
}

source "azure-arm" "windowsserver-2022" {
  azure_tags = {
    project = var.project
    created = local.timestamp
  }
  use_azure_cli_auth       = true
  location                 = var.location
  temp_resource_group_name = "tmp-packer${local.timestamp}"
  communicator             = "winrm"
  image_offer              = "WindowsServer"
  image_publisher          = "MicrosoftWindowsServer"
  image_sku                = "2022-datacenter-smalldisk-g2" # az vm image list-skus --location japaneast --publisher MicrosoftWindowsServer --offer WindowsServer --output table
  os_type                  = "Windows"
  vm_size                  = var.vm_size
  spot {
    max_price       = "-1"
    eviction_policy = "Deallocate"
  }

  allowed_inbound_ip_addresses = var.inbound_ip_addresses

  ## Note: Use the following parameters if you are building using an existing virtual network. In that case, disable the `allowed_inbound_ip_addresses` parameter.
  # private_virtual_network_with_public_ip = true
  # virtual_network_name = var.virtual_network_name
  # virtual_network_subnet_name = var.virtual_network_subnet_name
  # virtual_network_resource_group_name = var.virtual_network_resource_group_name

  winrm_insecure = true
  winrm_timeout  = "5m"
  winrm_use_ssl  = true
  winrm_username = "packer"
  winrm_password = var.winrm_password

  ## Note: If you want to save it as a managed image, specify the following parameters.
  # managed_image_name                = "win-2022-smalldisk-image-ja"
  # managed_image_resource_group_name = var.resource_group_name

  ## Note: If saving to Compute Gallery, specify the parameters in the `shared_image_gallery_destination` block.
  ## If you want to save to both, `specify managed_image_*` parameters for both.
  shared_image_gallery_destination {
    resource_group      = var.resource_group_name
    gallery_name        = var.gallery_name
    image_name          = var.image_definition
    image_version       = local.image_version
    replication_regions = var.replication_regions
  }
}

build {
  sources = ["source.azure-arm.windowsserver-2022"]

  # Transfer the registry files.
  provisioner "file" {
    source      = "${path.root}/registry/"
    destination = "C:/"
  }

  # Download and install language packs.
  provisioner "powershell" {
    scripts = [
      "${path.root}/scripts/install_language_pack_1.ps1",
    ]
  }

  provisioner "windows-restart" {}

  # Language Settings.
  provisioner "powershell" {
    scripts = [
      "${path.root}/scripts/install_language_pack_2.ps1",
    ]
  }

  provisioner "windows-restart" {}

  # Running Sysprep.
  provisioner "powershell" {
    inline = [
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /generalize /oobe /mode:vm /quiet /quit",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
