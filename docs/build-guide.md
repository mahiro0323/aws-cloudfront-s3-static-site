# 構築・再現手順

## 1. 検証の目的

S3をCloudFrontのオリジンとして使用し、独自ドメインとHTTPSで静的コンテンツを配信する流れを確認しました。

## 2. S3

静的コンテンツを保存するS3バケットを作成し、`index.html`をアップロードします。

```html
<!doctype html>
<html lang="ja">
  <head><meta charset="utf-8"><title>CloudFront Test</title></head>
  <body><h1>CloudFront / S3 Test</h1></body>
</html>
```

確認項目は次のとおりです。

- オリジンとして使用するバケットが正しいこと
- オブジェクトキーが正しいこと
- `index.html`が存在すること
- バケット名やアカウント情報を公開資料へ残さないこと

## 3. ACM

CloudFrontで独自ドメインを利用する証明書は、`us-east-1`で作成します。

1. ACMで独自ドメインの証明書をリクエスト
2. DNS検証を選択
3. Route 53へ検証用CNAMEを作成
4. 証明書が`Issued`になることを確認

## 4. CloudFront

Distributionへ次の項目を設定します。

- Origin: S3バケット
- Default root object: `index.html`
- Viewer protocol policy: HTTPからHTTPSへリダイレクト
- Alternate domain name: 独自ドメイン
- Custom SSL certificate: ACM証明書

設定後はDistributionの状態がデプロイ済みになるまで待ちます。

## 5. Route 53

独自ドメインのAliasレコードを作成し、CloudFront Distributionを指定します。

```text
レコードタイプ: A
Alias: 有効
ルーティング先: CloudFront Distribution
```

## 6. 動作確認

名前解決を確認します。

```bash
dig <DOMAIN_NAME>
```

HTTPSの応答を確認します。

```bash
curl -I https://<DOMAIN_NAME>/
```

ブラウザでは次を確認します。

- 証明書エラーが発生しないこと
- `index.html`が表示されること
- HTTPでアクセスした場合にHTTPSへ転送されること

## 7. キャッシュ確認

S3のファイルを更新しても表示が変わらない場合は、CloudFrontのキャッシュを確認します。

再検証時にInvalidationを行う場合の対象例です。

```text
/*
```

Invalidationは多用せず、検証時に必要な範囲で使用します。

