# Coding: UTF-8
require 'rbvmomi'

class Stems
  attr_accessor :vim, :HostSystem, :Vms, :CountersHost, :CountersVms
  
  def initialize opt
    self.vim = RbVmomi::VIM.connect opt
    self.HostSystem = HostSystem.new self.vim.root.childEntity[0].hostFolder.childEntity[0].host[0]
    self.Vms = Vms.new self.vim.serviceContent.rootFolder.childEntity[0].hostFolder.childEntity[0].host[0].vm
    self.CountersHost = CountersHost.new self.vim
    self.CountersVms = CountersVms.new self.vim, self.vim.serviceContent.rootFolder.childEntity[0].hostFolder.childEntity[0].host[0].vm
  end
  
  def vm name
    return self.vim.serviceContent.rootFolder.childEntity[0].find_vm(name)
  end
  
  class HostSystem
    attr_accessor :hostSystem
    
    def initialize hostSystem
      self.hostSystem = hostSystem
    end
    
    def cpuUsed #MHz
      return self.hostSystem.summary.quickStats.overallCpuUsage
    end
    
    def cpuMhz #MHz only 1CPU
      return self.hostSystem.summary.hardware.cpuMhz
    end
    
    def cpuCapacity
      return cpuMhz * cpuCores
    end
    
    def cpuThreads #Multi CPU Threads
      return self.hostSystem.summary.hardware.numCpuThreads
    end
    
    def cpuCores
      return self.hostSystem.summary.hardware.numCpuCores
    end
    
    def cpuRatio #%
      return cpuUsed / cpuCapacity.to_f
    end
    
    def cpuFree
      return cpuCapacity - cpuUsed
    end
    
    def cpuModel
      return self.hostSystem.summary.hardware.cpuModel
    end
    
    def memoryUsed #MB
      return self.hostSystem.summary.quickStats.overallMemoryUsage
    end
    
    def memoryCapacity #MB
      return self.hostSystem.summary.hardware.memorySize / (1024*1024)
    end
    
    def memoryRatio #%
      return memoryUsed / memoryCapacity.to_f
    end
    
    def memoryFree
      return memoryCapacity - memoryUsed
    end
    
    def uptime #sec
      return self.hostSystem.summary.quickStats.uptime
    end
  end
  
  class Vms
    attr_accessor :vms
    
    def initialize vms
      self.vms = vms
    end
    
    def vm num
      return Vm.new(self.vms[num])
    end
    
    def vm_by_obj obj
      return Vm.new(obj)
    end
    
    def operatingVms
      return self.vms.select{|vm|vm.runtime.powerState == "poweredOn"}
    end
    
    def operatingNum
      return self.vms.select{|vm|vm.runtime.powerState == "poweredOn"}.size
    end
    
    class Vm
      attr_accessor :vm
      
      def initialize vm
        self.vm = vm
      end
      
      def name
        return self.vm.name
      end
      
      def powerState
        return self.vm.summary.runtime.powerState
      end
      
      def cpuUsed #Mhz
        return self.vm.summary.quickStats.overallCpuUsage
      end
      
      def cpuThreads
        return self.vm.summary.config.numCpu
      end
      
      def memoryCapacity
        return self.vm.summary.config.memorySizeMB
      end
      
      def memoryUsed
        return self.vm.summary.quickStats.guestMemoryUsage
      end
      
      def memoryHostUsed
        return self.vm.summary.quickStats.hostMemoryUsage
      end
      
      def memoryFree
        return memoryCapacity - memoryUsed
      end
      
      def memoryRatio
        return memoryUsed / memoryCapacity.to_f
      end
      
      def uptime
        return self.vm.summary.quickStats.uptimeSeconds
      end
    end
  end
  
  class CountersHost
    attr_accessor :vim, :host
    
    def initialize vim
      self.vim = vim
      self.host = self.vim.root.childEntity[0].hostFolder.childEntity[0].host
    end
    
    def counter metrics
      counter = self.vim.serviceContent.perfManager.retrieve_stats(self.host, metrics)
      return counter[host[0]][:metrics]
    end
    
    def power
      return counter(["power.power"])["power.power"][0]
    end
  end
  
  class CountersVms
    attr_accessor :vim, :vms
    
    def initialize vim, vms
      self.vim = vim
      self.vms = vms
    end
    
    def counter metrics
      counters = vim.serviceContent.perfManager.retrieve_stats(self.vms, metrics)
      hash = {}
      counters.size.times do |i|
        key, value = counters.shift
        hash[key.name] = value[:metrics]
      end
      return hash
    end
    
    def power
      return counter ["power.power"]
    end
  end
end