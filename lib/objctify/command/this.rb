#
# Copyright Devexperts (2019)
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

module Objctify
  class Command
    class This < Command
      self.summary = 'Creates xcodeproj from java sources with j2objc'
      self.description = 'Creates xcodeproj from java source with j2objc using configuration from Objctifile'

      def run
        file_path = "#{Dir.pwd}/Objctifile"

        unless File.exist?(file_path)
          raise Objctify::Informative, "Couldn't find Objctifile"
        end

        file_contents = File.read(file_path)

        project = Context.new
        project.instance_eval(file_contents, file_path)

        if project.project_name_param.nil?
          raise Objctify::Informative, "Project name is not provided in Objctifile"
        end
        if project.java_sources_param.nil?
          raise Objctify::Informative, "Path to Java sources is not provided in Objctifile"
        end

        raise Objctify::Informative, "Provided Java sources directory does not exist: #{project.java_sources_param}" unless
            Dir.exist?(project.java_sources_param)

        framework_name = project.project_name_param
        java_sources = File.expand_path(project.java_sources_param)
        j2objc_home = File.expand_path(project.j2objc_config.distr_dir)
        dependencies = project.project_dependencies_param

        raise Objctify::Informative, "J2ObjC home directory does not exist: #{j2objc_home}" unless
            Dir.exist?(j2objc_home)
        raise Objctify::Informative, "J2ObjC home directory does not contain j2objc: #{j2objc_home}" unless
            File.exist?("#{j2objc_home}/j2objc")

        unless project.j2objc_config.prefixes_file_path.nil?
          unless File.exist?(project.j2objc_config.prefixes_file_path)
            raise Objctify::Informative, "Specified prefixes file does not exist: #{project.j2objc_config.prefixes_file_path}"
          end

          prefix_file_path = File.expand_path(project.j2objc_config.prefixes_file_path)
        end

        Objctify::translate_files(java_sources, prefix_file_path, j2objc_home, framework_name, dependencies, project.j2objc_config.extra_cli_args)
        puts 'Cleaning'
        Objctify::fix_imports(framework_name, prefix_file_path)
        puts 'Plumbing'
        useArc = project.j2objc_config.extra_cli_args.include? "-use-arc"
        Objctify::generate_project(framework_name, j2objc_home, useArc)
        puts 'Done'
      end
    end
  end
end
