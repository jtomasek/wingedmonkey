# Copyright 2012-2013 Red Hat, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

module Providers
  module Ovirt
    class OvirtProviderApplication < ProviderApplication
      attr_accessor :ips, :creation_time, :cores, :memory

      validates_numericality_of :cores

      def launchable
        Launchable.find(@launchable_id)
      end

      def launch
        self.class.connect! do |client|
          vm = client.create_vm(:name => @name,
                                :template => @launchable_id,
                                :cores => @cores
                                )
          client.vm_action(vm.id, :start)
          @id = vm.id 
        end
      end

      def destroy
        self.class.connect! do |client|
          client.destroy_vm id
        end
      end

      def self.all filter=nil
        connect! do |client|
          client.vms.map do |vm|
            self.map_vm_to_application vm
          end
        end
      end

      def self.find id
        connect! do |client|
          vm = client.vm(id)
          self.map_vm_to_application vm
        end
      end

      private

      def self.map_vm_to_application vm
        state = vm.status.strip
        wm_state = case state
                   when "image_locked", "powering_up" then ProviderApplication::WM_STATE_PENDING
                   when "up" then ProviderApplication::WM_STATE_RUNNING
                   when "down" then ProviderApplication::WM_STATE_STOPPED
                   when "powering_down" then ProviderApplication::WM_STATE_STOPPING
                   else ProviderApplication::WM_STATE_FAILED
                   end

        ProviderApplication.create({
                                     :id => vm.id,
                                     :launchable_id => vm.template.id,
                                     :name => vm.name,
                                     :state => state,
                                     :wm_state => wm_state,
                                     :ips => vm.ips,
                                     :creation_time => vm.creation_time,
                                     :memory => vm.memory.strip,
                                     :cores => vm.cores
                                   })
      end
    end
  end
end
