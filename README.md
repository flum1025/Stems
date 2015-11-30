Stems
===========

##What is it?

StemsとはESXi-VMs statisticsをもじった名前でESXi上の仮想マシンのデータとHostサーバーのデータを取得し、Googleスプレッドシートを仕様し、グラフ化するRubyアプリケーションです。  

動作確認はruby 2.0.0p481及びruby 2.1.0ですがruby 1.9.3でも動くと思います。

##How to Use
Rubyのインストールは省きます。 
準備としてStems/に移動しbundle installを実行してください。  
　  
まず、[ここ](http://qiita.com/yumiyon/items/d7c370b3b8582431a3de)を参考にGoogle APIのクライアント ID、クライアント シークレット、リフレッシュトークン及びスプレッドシート IDを取得してください。  
それぞれstems.rb上の該当部分に書き込んでください。  
　　  
次にStems初期化の部分のStems.newの後にオプションとしてRbVmomi::VIM.connectと同じオプションを書き込んでください。
[RbVmomi](https://github.com/rlane/rbvmomi)  

　　  
後はcron等で定期的に実行することで指定のスプレッドシートにデータが書き込まれていきます。  
スプレッドシート上で任意のデータを選択しグラフ化することでHTMLにも貼り付けられるリアルタイムで更新されるグラフを作成することができます。



##Class Methods

###Stems
####　vm(name)
>>nameからRbVmomi::VIM::VirtualMachineオブジェクトを取得します
####　vim
>>RbVmomi::VIMオブジェクトを取得します
####　HostSystem
>>Stems::HostSystemオブジェクトを取得します
####　Vms
>>Stems::Vmsオブジェクトを取得します
####　CountersHost
>>Stems::CountersHostオブジェクトを取得します
####　CountersVms
>>Stems::CountersVmsオブジェクトを取得します
###Stems::HostSystem
>>ESXiホストの情報を取得するオブジェクトです
####cpuUsed
>>使用しているCPU値を取得します(Mhz)
####cpuMhz
>>CPU１コアのクロック数を取得します(Mhz)
####cpuCapacity
>>搭載しているCPU全体の総クロック数を取得します(Mhz)
####cpuThreads
>>CPUのスレッド数を取得します
####cpuCores
>>CPUのコア数を取得します
####cpuRatio
>>CPUの使用率を取得します(%)
####cpuFree
>>CPUの空きを取得します(Mhz)
####cpuModel
>>CPUのモデル名を取得します
####memoryUsed
>>使用しているメモリ値を取得します(MB)
####memoryCapacity
>>メモリの総搭載値を取得します(MB)
####memoryRatio
>>メモリの使用率を取得します(%)
####memoryFree
>>メモリの空きを取得します(MB)
####uptime
>>稼働時間を取得します(sec)
###Stems::Vms
>>Stems::Vms::Vmオブジェクトを取得するオブジェクトです
####vm(num)
>>num番目の仮想マシンのStems::Vms::Vmオブジェクトを取得します
####vm_by_obj(obj)
>>RbVmomi::VIM::VirtualMachineオブジェクトからStems::Vms::Vmオブジェクトを取得します
####operatingVms
>>現在稼働中の仮想マシンのオブジェクトを取得します(Array)
####operatingNum
>>現在稼働中の仮想マシンの数を取得します
###Stems::Vms::Vm
>>仮想マシンを情報を取得するオブジェクトです
####name
>>仮想マシン名を取得します
####powerState
>>仮想マシンの稼働状況を取得します
####cpuUsed
>>使用しているCPU値を取得します(Mhz)
####cpuThreads
>>割り当てられているスレッド数を取得します
####cpuCapacity
>>割り当てられているCPUの総クロック数を取得します(Mhz)
####memoryUsed
>>使用しているメモリ値を取得します(MB)
####memoryHostUsed
>>仮想マシンが消費しているホストメモリを取得します(MB)
####memoryFree
>>メモリの空きを取得します(MB)
####memoryRatio
>>メモリの使用率を取得します(MB)
####uptime
>>稼働時間を取得します(sec)
###Stems::CountersHost
>>ホストのパフォーマンスカウンタを取得するオブジェクトです
####counter(metrics)
>>任意のカウンタを取得します
####power
>>ホストの消費電力を取得します
###Stems::CountersVms
>>仮想マシンのパフォーマンスカウンタを取得するオブジェクトです
####counter(metrics)
>>任意のカウンタを取得します
####power
>>仮想マシンの消費電力を取得します


##Notice
特定の仮想マシンの状態のみ取得したい場合はstems.vmでオブジェクトを取得し、stems.Vms.vm_by_objでデータ取得用のオブジェクトを取得する  

起動中の仮想マシンに関わらず全て取得する場合はoperatingVmsメソッドではなくstems.Vms.vmsをeachで回しstems.Vms.vmかstems.Vms.vm_by_objで取得する  

消費電力以外のパフォーマンスカウンタを取得する場合はstems.CountersHost.counterかstems.CountersVms.counterで取得する  

下記以外のデータ取得メソッドは作ってないので自力でRbvmomiから取得するかTwitter(@flum_)までリプライをくれれば作ります  
stems.vimにRbVmomi::VIMオブジェクト  
stems.HostSystem.hostSystemにRbVmomi::VIM::HostSystemオブジェクト  
stems.Vms.vmsにRbVmomi::VIM::VirtualMachineが配列で格納されています。  

質問等ありましたらTwitter:[@flum_](https://twitter.com/flum_)までお願いします。  

##License

The MIT License

-------
(c) @2015 flum_