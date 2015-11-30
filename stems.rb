# Coding: UTF-8
path = File.expand_path('../', __FILE__)
require File.join(path, 'core/Stems.rb')
require File.join(path, 'core/SpreadSheet.rb')
require 'sqlite3'

###SpreadSheet設定
client_id     = ""
client_secret = ""
refresh_token = ""
spread_id = ""
###ここまで

###SpreadSheet初期化
spreadSheet = SpreadSheeet.new  client_id, client_secret, refresh_token, spread_id

###Sqlite3初期化
sqlite = SQLite3::Database.open(File.join(path, 'data/data.db'))
  
###初めての実行の時はコメントアウトを外してテーブルを作る
#sqlite.execute "CREATE TABLE IF NOT EXISTS host(date TEXT, cpuUsed TEXT, cpuFree TEXT, cpuRatio TEXT, memoryUsed TEXT, memoryFREE TEXT, memoryRatio TEXT, uptime TEXT, operatingVms TEXT, w TEXT)"
#sqlite.execute "CREATE TABLE IF NOT EXISTS vms(date TEXT, name TEXT, cpuUsed TEXT, cpuFree TEXT, cpuRatio TEXT, memoryUsed TEXT, memoryFREE TEXT, memoryRatio TEXT, uptime TEXT, w TEXT)"

###Stems初期化 引数はRbVmomi::VIM.connectする時と同じ引数
stems = Stems.new host: '', port: 443, user: '', password: '',  insecure: true

###hostデータ作成
data = [
  Time.now.strftime("%Y-%m-%d %H:%M:%S"),
  stems.HostSystem.cpuUsed,
  stems.HostSystem.cpuFree,
  stems.HostSystem.cpuRatio,
  stems.HostSystem.memoryUsed,
  stems.HostSystem.memoryFree,
  stems.HostSystem.memoryRatio,
  stems.HostSystem.uptime,
  stems.Vms.operatingNum,
  stems.CountersHost.power
]

###データベースに格納
sqlite.execute"INSERT INTO host VALUES(?,?,?,?,?,?,?,?,?,?)", data

###SpreadSheetに一日分を保存(10分ごとにcronしてる場合)
if spreadSheet.num_rows > 145
  spreadSheet.write(sqlite.execute "SELECT * FROM host ORDER BY DATE DESC LIMIT 144")
else
  spreadSheet.hostPush data
end

###上の各仮想マシン用
stems.Vms.operatingVms.each do |vmu|
  vm = stems.Vms.vm_by_obj vmu
  spreadSheet.worksheet_by_title(vm.name)
  data = [
    Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    vm.name,
    vm.cpuUsed,
    (stems.HostSystem.cpuMhz * vm.cpuThreads) - vm.cpuUsed,
    vm.cpuUsed / (stems.HostSystem.cpuMhz * vm.cpuThreads).to_f,
    vm.memoryUsed,
    vm.memoryFree,
    vm.memoryRatio,
    vm.uptime,
    stems.CountersVms.power[vm.name]["power.power"][0]
  ]
  sqlite.execute"INSERT INTO vms VALUES(?,?,?,?,?,?,?,?,?,?)", data
  if spreadSheet.num_rows > 145
    spreadSheet.write(sqlite.execute "SELECT * FROM vms WHERE name = '#{vm.name}' ORDER BY DATE DESC LIMIT 144")
  else
    spreadSheet.vmPush data
  end
end

=begin
特定の仮想マシンの状態のみ取得したい場合はstems.vmでオブジェクトを取得し、
stems.Vms.vm_by_objでデータ取得用のオブジェクトを取得する

起動中の仮想マシンに関わらず全て取得する場合はoperatingVmsメソッドではなく
stems.Vms.vmsをeachで回しstems.Vms.vmかstems.Vms.vm_by_objで取得する

消費電力以外のパフォーマンスカウンタを取得する場合はstems.CountersHost.counterかstems.CountersVms.counterで取得する

下記以外のデータ取得メソッドは作ってないので自力でRbvmomiから取得するかTwitter(@flum_)までリプライをくれれば作ります
stems.vimにRbVmomi::VIMオブジェクト
stems.HostSystem.hostSystemにRbVmomi::VIM::HostSystemオブジェクト
stems.Vms.vmsにRbVmomi::VIM::VirtualMachineが配列で格納されています。


###データ取得するメソッド
#Host
  stems.HostSystem.cpuUsed
  stems.HostSystem.cpuMhz
  stems.HostSystem.cpuCapacity
  stems.HostSystem.cpuThreads
  stems.HostSystem.cpuCores
  stems.HostSystem.cpuRatio
  stems.HostSystem.cpuFree
  stems.HostSystem.cpuModel
  stems.HostSystem.memoryUsed
  stems.HostSystem.memoryCapacity
  stems.HostSystem.memoryRatio
  stems.HostSystem.memoryFree
  stems.HostSystem.uptime
  stems.CountersHost.power
  stems.CountersHost.counter

#Vms
  vm.name
  vm.powerState
  vm.cpuUsed
  vm.cpuThreads
  vm.memoryCapacity
  vm.memoryUsed
  vm.memoryHostUsed
  vm.memoryFree
  vm.memoryRatio
  vm.uptime
  stems.CountersVms.power
  stems.CountersVms.counter
=end