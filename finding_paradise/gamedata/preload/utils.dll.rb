# Compatibility for Utils.dll (AowVN / Freebird Games)
# Provides AVSetEnv, IsFullScreen, and path normalization for Linux

unless defined?($__utils_dll_loaded)
	$__utils_dll_loaded = true

	save_dir = ENV['XDG_DATA_HOME'] || ENV['AV_APPDATA'] || '.'
	ENV['AV_APPDATA'] = save_dir.to_s.tr('\\', '/').chomp('/')

	module Win32API_Impl
		module Utils
			class AVSetEnv
				def call(args = nil)
					save_dir = ENV['XDG_DATA_HOME'] || ENV['AV_APPDATA'] || '.'
					save_dir = save_dir.to_s.tr('\\', '/').chomp('/')
					ENV['AV_APPDATA'] = save_dir
					return 1
				end
			end

			class IsFullScreen
				def call(args = nil)
					if defined?(Graphics.fullscreen)
						return Graphics.fullscreen ? 1 : 0
					end
					return 1
				end
			end
		end
	end
end

# Normalize backslash paths on Linux to forward slash
unless defined?($__path_normalizer_installed)
	$__path_normalizer_installed = true

	class << Dir
		alias_method :__safe_orig_dir_mkdir, :mkdir
		def mkdir(path, *args)
			p = path.to_s.tr('\\', '/')
			return 0 if File.exist?(p)
			begin
				__safe_orig_dir_mkdir(p, *args)
			rescue Errno::ENOENT
				parts = p.split('/')
				cur = parts[0].empty? ? '/' : ''
				parts.each do |part|
					next if part.empty?
					cur = (cur == '/' ? "/#{part}" : (cur.empty? ? part : "#{cur}/#{part}"))
					unless File.exist?(cur)
						begin
							__safe_orig_dir_mkdir(cur)
						rescue => e
						end
					end
				end
			rescue => e
			end
		end

		def exist?(path)
			FileTest.exist?(path.to_s.tr('\\', '/'))
		end
		def exists?(path)
			FileTest.exist?(path.to_s.tr('\\', '/'))
		end
	end

	class << File
		alias_method :__safe_orig_file_exist?, :exist?
		def exist?(path)
			__safe_orig_file_exist?(path.to_s.tr('\\', '/'))
		end
		def exists?(path)
			__safe_orig_file_exist?(path.to_s.tr('\\', '/'))
		end

		alias_method :__safe_orig_file_open, :open
		def open(path, *args, &block)
			__safe_orig_file_open(path.to_s.tr('\\', '/'), *args, &block)
		end

		alias_method :__safe_orig_file_new, :new
		def new(path, *args, &block)
			__safe_orig_file_new(path.to_s.tr('\\', '/'), *args, &block)
		end
	end

	module FileTest
		class << self
			alias_method :__safe_orig_filetest_exist?, :exist?
			def exist?(path)
				__safe_orig_filetest_exist?(path.to_s.tr('\\', '/'))
			end
			def exists?(path)
				__safe_orig_filetest_exist?(path.to_s.tr('\\', '/'))
			end
		end
	end

	module Kernel
		private
		alias_method :__safe_orig_kernel_open, :open
		def open(path, *args, &block)
			if path.is_a?(String)
				__safe_orig_kernel_open(path.tr('\\', '/'), *args, &block)
			else
				__safe_orig_kernel_open(path, *args, &block)
			end
		end
		module_function :open
	end
end
