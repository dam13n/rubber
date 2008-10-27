
namespace :rubber do

  namespace :haproxy do
  
    rubber.allow_optional_tasks(self)
  
    after "rubber:install_packages", "rubber:haproxy:custom_install"
    
    task :custom_install, :roles => :web do
      ver = "1.3.15.2-1_i386"
      rubber.run_script 'install_haproxy', <<-ENDSCRIPT
        if [[ ! -f /usr/sbin/haproxy ]]; then
          rm -rf /tmp/*haproxy*
          wget -qP /tmp "http://http.us.debian.org/debian/pool/main/h/haproxy/haproxy_#{ver}.deb"
          dpkg -i haproxy_#{ver}.deb
        fi
      ENDSCRIPT
    end
  
    # serial_task can only be called after roles defined - not normally a problem, but
    # rubber auto-roles don't get defined till after all tasks are defined
    on :load do
      rubber.serial_task self, :serial_restart, :roles => :web do
        run "/etc/init.d/haproxy restart"
      end
      rubber.serial_task self, :serial_reload, :roles => :web do
        run "/etc/init.d/haproxy reload"
      end
    end
    
    before "deploy:stop", "rubber:haproxy:stop"
    after "deploy:start", "rubber:haproxy:start"
    after "deploy:restart", "rubber:haproxy:serial_restart"
    
    desc "Stops the haproxy server"
    task :stop, :roles => :web, :on_error => :continue do
      run "/etc/init.d/haproxy stop"
    end
    
    desc "Starts the haproxy server"
    task :start, :roles => :web do
      run "/etc/init.d/haproxy start"
    end
    
    desc "Restarts the haproxy server"
    task :restart, :roles => :web do
      serial_restart
    end
  
    desc "Reloads the haproxy web server"
    task :reload, :roles => :web do
      serial_reload
    end
  
  end

end