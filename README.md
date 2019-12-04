# clouflarea-auto-firewall
Auto open firewallrules

详细食用方法
<a href="https://cangshui.net/?p=4516">https://cangshui.net/?p=4516</a>

## 教程

下载脚本

```shell
wget -N --no-check-certificate https://raw.githubusercontent.com/julydate/clouflarea-auto-firewall/master/cfauto.sh /tmp/cfauto.sh && chmod +x /tmp/cfauto.sh
```

开始一步步填写脚本里的变量

```shell
vim /tmp/cfauto.sh
```

第一行的 email 变量填的是你 CloudFlare 账号的登录邮箱

第二行的 globalapi 变量，填写的是下图这里的 key，这个页面需要右上角点头像，然后点击 My Profile 里 API Tokens 菜单里

![1](https://raw.githubusercontent.com/julydate/clouflarea-auto-firewall/master/img/1.jpg)

打开 Cloudflare Firewall Rule 页面添加防火墙规则

![2](https://raw.githubusercontent.com/julydate/clouflarea-auto-firewall/master/img/2.jpg)

随便设一个访客不可能使用的 IP，再添加一条规则，让可信任的爬虫正常访问，最后设置开启验证码

![3](https://raw.githubusercontent.com/julydate/clouflarea-auto-firewall/master/img/3.jpg)

rulesid1 和 rulesid2 需要打开 Cloudflare Firewall Rule 页面，按 F12 打开控制台，然后找到你刚刚添加的规则，开启或关闭他，在控制台的 network 功能里找到如图所示的请求，6 的位置为第一个 key 填在 rulesid1 变量，7的位置为第二个key填在 rulesid2变量里

![4](https://raw.githubusercontent.com/julydate/clouflarea-auto-firewall/master/img/4.jpg)

zoneid 这个变量打开你的域名总览页面，然后看右下角，往下翻页，找到如图所示的位置

![5](https://raw.githubusercontent.com/julydate/clouflarea-auto-firewall/master/img/5.jpg)

![6](https://raw.githubusercontent.com/julydate/clouflarea-auto-firewall/master/img/6.jpg)

到这里差不多就配置完了，默认的是5秒内CPU占用持续超过85开启验证码，然后240秒后占用下降了自动关盾

配置完之后，你需要设置一个 crontab 定时任务来执行脚本，设置个1分钟就行了

```shell
*/1 * * * * /bin/bash /tmp/cfauto.sh >> /tmp/cfautolog.log 2>&1 &
```

如果需要每 30s 执行一次，可以通过 crontab 中增加延迟30秒来实现

```she
*/1 * * * * /bin/bash /tmp/cfauto.sh >> /tmp/cfautolog.log 2>&1 &
*/1 * * * * sleep 30; /bin/bash /tmp/cfauto.sh >> /tmp/cfautolog.log 2>&1 &
```

