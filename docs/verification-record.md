# 検証内容と切り分け記録

## サービスごとの役割

| サービス | 確認した役割 |
|---|---|
| Route 53 | 独自ドメインの名前解決 |
| ACM | HTTPSで使用する証明書 |
| CloudFront | CDN、HTTPS終端、キャッシュ配信 |
| S3 | 静的コンテンツを保存するオリジン |

## 接続確認の順序

### 1. DNS

- Route 53のAlias先がCloudFrontか
- 対象ドメインのHosted Zoneを使用しているか
- DNS変更が反映されているか

### 2. 証明書

- ACM証明書が`Issued`か
- 証明書が`us-east-1`にあるか
- CloudFrontのAlternate domain nameと証明書のドメインが一致するか

### 3. CloudFront

- Distributionがデプロイ済みか
- Originに正しいS3バケットを指定しているか
- Default root objectが設定されているか
- Viewer protocol policyが想定どおりか

### 4. S3

- 対象ファイルが存在するか
- ファイル名の大文字・小文字が一致しているか
- CloudFrontからS3へアクセスできる設定か

### 5. キャッシュ

- 古いファイルがCloudFrontに残っていないか
- S3の更新時刻とCloudFrontの応答を比較
- 必要な場合だけInvalidationを実施

## HTTPレスポンスで見る項目

```bash
curl -I https://<DOMAIN_NAME>/
```

確認対象の例です。

```text
HTTPステータス
server
via
x-cache
age
```

`x-cache`などのヘッダーを見ることで、CloudFrontを経由しているか判断できます。

## OAC / OAIについて

当時の記録から、OACまたはOAIのどちらを設定したか確認できませんでした。そのため、設定済みとは記載していません。

再検証するときは、次を確認してから追記します。

1. S3のBlock Public Access
2. CloudFrontのOrigin access設定
3. S3バケットポリシー
4. S3 URLへ直接アクセスした場合の結果
5. CloudFront経由でアクセスした場合の結果

## 記録の範囲

S3、CloudFront、Route 53、ACMを組み合わせたHTTPS配信と、設定・接続の切り分けを学習しました。ただし、実際のドメイン名、バケット名、Distribution ID、レスポンスヘッダーの保存結果は掲載していません。

不明な設定を補完せず、再現できる手順と確認観点を記録しています。
