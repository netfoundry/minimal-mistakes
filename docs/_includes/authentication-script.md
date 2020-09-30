## Script

Pull it all together with [HTTPie (command-line HTTP client)](https://httpie.org/) and [`jq` (command-line JSON processor)](https://stedolan.github.io/jq/).

```bash
❯ export  NETFOUNDRY_CLIENT_ID=1st50d7si3dnu275bck2bd228m \
          NETFOUNDRY_PASSWORD=1lhfgel7fi048nabt0f74ghckqbj5lsbmqa1g101ud9a935edhv8 \
          NETFOUNDRY_OAUTH_URL=https://netfoundry-sandbox-hnssty.auth.us-east-1.amazoncognito.com/oauth2/token
❯ source ./export-netfoundry-api-token.bash
```

Download [export-netfoundry-api-token.bash](/assets/export-netfoundry-api-token.bash)

<!-- {% highlight bash %}
{% include export-netfoundry-api-token.bash %}
{% endhighlight %}
 -->
