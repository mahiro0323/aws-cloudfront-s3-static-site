# TerraformでCloudFront + S3を作成する

## 目的と範囲

簡単なHTMLやブラウザ上で動くアプリを公開するため、S3とCloudFrontをコードで作成できるようにしました。既存のAWSリソースを取り込むコードではなく、別の学習環境を新規作成します。サーバーで実行するPythonやNode.js、データベース、秘密のAPIキーは配置できません。

作成するのはS3バケット、パブリックアクセスブロック、暗号化設定、OAC、CloudFront、バケットポリシー、index.htmlの7リソースです。S3のWebサイトエンドポイントではなくRESTエンドポイントを使用します。

CloudFront標準ドメインの証明書でHTTPS配信します。既存の構成図にあるRoute 53と独自ドメイン用ACMは対象外です。PriceClass_100は日本のエッジを含まないため、日本向けの速度より配信エリアを絞ることを優先した設定です。

## ファイル

| ファイル | 内容 |
|---|---|
| terraform/versions.tf | Terraform・AWSプロバイダーのバージョン、リージョン |
| terraform/variables.tf | 環境名とリージョン |
| terraform/main.tf | S3、公開ブロック、暗号化 |
| terraform/cloudfront.tf | CloudFront、OAC、S3の読み取り許可 |
| terraform/site.tf | HTMLをS3に配置 |
| terraform/outputs.tf | 確認用URLとID |
| terraform/site/index.html | 公開するサンプルページ |

## 準備

Terraform 1.17以上2未満、AWS CLI、対象アカウントでのS3とCloudFrontの作成権限が必要です。AWS認証は手元で設定し、認証情報をコードに記載しません。

```sh
cd terraform
aws sts get-caller-identity
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
```

デフォルトは東京リージョン、環境名はmahiro-tf-static-siteです。変更する場合はplanに `-var='project_name=my-demo'` を指定します。複数環境を同時に持つ場合は、環境ごとに作業ディレクトリとstateを分け、異なるproject_nameを使ってください。

planで作成内容と接続先アカウントを確認します。既存環境の変更・削除が出た場合は適用せず、stateと作業場所を確認してください。

## 作成

```sh
terraform apply tfplan
terraform output -raw cloudfront_url
```

CloudFrontの作成には時間がかかります。applyが完了するまで待ってから次の確認を行います。初期のエラーがキャッシュされている場合は少し待って再確認します。

## 動作確認

```sh
curl -I "$(terraform output -raw cloudfront_url)/"
curl -I "$(terraform output -raw s3_direct_url)"
```

CloudFront経由は200、S3への匿名直接アクセスは403を期待します。ブラウザでもサンプルページを確認します。

```sh
aws s3api get-public-access-block --bucket "$(terraform output -raw s3_bucket_name)"
terraform plan -detailed-exitcode
```

公開ブロックの4項目がtrueであること、再planの終了コードが0（変更なし）であることを確認します。終了コード2は差分あり、1はエラーです。これらは期待値であり、実際に確認するまでは検証済みと記載しません。

## HTMLを更新する

`site/index.html` を変更してplanとapplyを実行します。ファイルのハッシュの変化でS3の更新を検出します。追加のCSS・JS・画像を使う場合は、対応するaws_s3_objectとContent-Typeもコードに追加してください。現状、自動アップロードの対象はindex.htmlのみです。

キャッシュはHTMLのCache-Controlで300秒に設定しています。即時に更新したい場合は次を実行します。

```sh
aws cloudfront create-invalidation --distribution-id "$(terraform output -raw cloudfront_distribution_id)" --paths '/index.html' '/'
```

## 削除

```sh
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

このstateで管理している学習環境が削除対象であることを確認してから適用してください。コードで管理しているindex.htmlは削除されます。手動で追加したファイルが残っている場合はバケットの削除が失敗します。中身を確認して対処し、無条件の全削除は行いません。

stateは削除が完了するまで保管します。stateを失うとTerraformから対象リソースを追跡できなくなります。

## Gitに含めるもの

`.tf`、サンプルHTML、`.terraform.lock.hcl` をコミットします。`.terraform/`、state、tfvars、保存したplanは除外します。planとstateにはアカウント情報などが含まれるため、公開しません。ローカルstateはアクセス制限された場所で別途バックアップしてください。

## 費用

無料を保証する構成ではありません。保存容量、リクエスト、転送量、キャッシュ無効化等に応じて利用料金が発生し、無料枠の適用条件はアカウントによって異なります。利用前にAWSの料金と請求画面を確認し、不要になったら上記の手順で削除します。このコードは予算アラートを作成しません。

## 参照

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
- https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
- https://aws.amazon.com/cloudfront/pricing/
- https://aws.amazon.com/s3/pricing/
