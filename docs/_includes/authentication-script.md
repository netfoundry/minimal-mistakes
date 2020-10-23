## Script

Conveniently use your API account in a shell with this script.

```bash
# get an API token with the default API account ~/.netfoundry/credentials.json
❯ source ./export-netfoundry-api-token.bash
```

```bash
# or override the default credentials file to use a different API account
❯ NETFOUNDRY_API_ACCOUNT=~/Downloads/example-account.json \
    source ./export-netfoundry-api-token.bash
```

#### Get the Script 

[download](/assets/export-netfoundry-api-token.bash){: .btn .btn--info .btn--x-large}

<details>
<summary>Preview</summary>

{% highlight bash %}
{% include export-netfoundry-api-token.bash %}
{% endhighlight %}

</details>  
