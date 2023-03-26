# Azure Windows VM Image with Packer

このリポジトリには、Packerを使用してWindows Server 2022 (smalldisk) のAzure VMイメージを日本語化するためのコードが含まれています。

## 前提条件

- イメージの保存先となる Azure Compute Gallery はあらかじめ作成しておく必要があります。
- ローカル実行環境は .devcontainer で構築するUbuntuのコンテナを使用します。(Docker, VSCodeが必要)
- ビルドを実行する前に `az login` コマンドでAzureにサインインしておく必要があります。

## 実行方法

1. [Visual Studio Code](https://code.visualstudio.com/) を開き、[Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 拡張機能をインストールしてください。
2. Visual Studio Codeでこのリポジトリを開き、左下の緑色のアイコンをクリックし、「Reopen in Container」を選択してください。これにより、devcontainer.jsonに基づいたUbuntuコンテナが起動します。
3. コンテナ内で `az login` を実行して、Azureにサインインします。
4. `*.auto.pkrvars.hcl` ファイルを作成して、インプット変数を定義します。
   `vm_size` はスポットVMで利用可能なサイズを指定します。
   `inbound_ip_addresses` を指定すると、Packerがビルド実行するための仮想ネットワーク(サブネット)にNSGが作成されます。
   以下は `auto.pkrvars.hcl` ファイルの記述例です。

   ```
   project              = "MyProject"
   location             = "japaneast"
   resource_group_name  = "packer-rg"
   vm_size              = "Standard_DS1_v2"
   gallery_name         = "windows_sig"
   image_definition     = "2022-datacenter-smalldisk-g2"
   image_version        = "1.0.0"
   replication_regions  = ["japaneast"]
   winrm_password       = "P@ssw0rd!"
   inbound_ip_addresses = ["xxx.xxx.xxx.xxx"]
   ```
5. `packer validate` コマンドを使用して構文をチェックします。

   ```
   packer validate .
   ```
6. 問題なければ  `packer build` コマンドを使用してビルドします。

   ```
   packer build .
   ```
