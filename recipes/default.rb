raise "version is required attributes." unless node[:luajit][:version]

version      = node[:luajit][:version]
ext          = node[:luajit][:ext]
src_dir      = "LuaJIT-#{version}"
src_file     = "#{src_dir}#{ext}"
download_url = "#{node[:luajit][:download_url]}/#{src_file}"
tmp_dir      = node[:luajit][:tmp_dir]
tmp_file     = "#{tmp_dir}/#{src_file}"
install_dir  = node[:luajit][:install_dir]
luajit_bin   = "#{install_dir}/bin/luajit"
cmd          = node[:luajit][:mv_src] ? "mv #{src_dir} #{install_dir}/src/" : "rm -rf #{src_dir}"

remote_file tmp_file do
  source download_url
  owner  "root"
  mode   0644
  not_if { File.exists? luajit_bin }
end

bash "install luajit" do
  user "root"
  cwd  tmp_dir
  code <<-EOH
    tar zxvf #{tmp_file}
    cd #{src_dir}
    make
    make install PREFIX=#{install_dir}
    cd ../
    #{cmd}
  EOH
  
  not_if { File.exists? luajit_bin }
end

file tmp_file do
  action :delete
  only_if { File.exists? luajit_bin }
end
