require "json"
require "open-uri"

class MaxSizeDetector
  class Base
    attr_reader :input_file, :lines, :files, :directories, :output

    def initialize(**opts)
      filename = opts[:filename] || opts[:file]
      @input_file = open(filename)
      @max_size = opts[:max_size].to_i
      @lines = Array.new
      @files = Hash.new
      @output = Hash.new

    rescue => error
      print " FAILED!\n#{error}"
    end

    def extract!
      return unless @input_file

      extract_lines!
      extract_files!
    end

    def process!
      return unless @input_file

      files_within_max_size = extract_files_by_max_size
      grouped = group_by(hash_key: :parent_directory, files: files_within_max_size)
      content_to_hash!(grouped)

      @output = extract_files_by_max_size(files: grouped)
      output_within_max_size!
    end

    def show_output
      JSON.pretty_generate(JSON.parse(@output.to_json))
    end

    protected

    def extract_lines!
      @lines = @input_file.readlines.map do |line|
        line_str = line.to_s
        line_str.end_with?("\n") ? line_str[0..-2] : line_str
      end
    end

    def extract_files!
      keys = {}
      @lines.each_with_index do |line, idx|
        next unless file?(line)

        parts = extract_file(line)
        filename = parts.keys.first
        filename!(keys, filename)

        file = init_file(filename)
        file_hash = file[filename]
        file_hash[:size] = parts[filename]

        parent_directory!(file_hash, idx)

        @files.merge!(file)
      end
    end

    def output_within_max_size!
      new_output = Array.new
      @output.to_a.repeated_combination(2) do |combi|
        a = combi.first
        b = combi.last
        next if a == b

        a_val = a[1]
        b_val = b[1]
        total = a_val[:size].to_i + b_val[:size].to_i
        next if total > @max_size

        c = new_total = nil
        @output.each do |key, val|
          next unless percent_up?(val[:size].to_i + total, percent: 80)
          
          c = [key, val]
          new_total = val[:size].to_i + total
          break
        end

        if new_total && new_total < @max_size && a[0] != c[0] && b[0] != c[0]
          new_output << Hash[
            a[0] => a_val,
            b[0] => b_val,
            c[0] => c[1],
            total: new_total
          ]
        elsif percent_up?(total, percent: 80)
          new_output << Hash[
            a[0] => a_val,
            b[0] => b_val,
            total: total
          ]
        end
      end

      @output = new_output.sort_by { |no| -no[:total] }
    end

    private

    def directory?(command)
      return false if command.start_with?("$")

      command.include?("dir ")
    end

    def file?(command)
      return false if directory?(command) ||
                      command.start_with?("$")

      extract_file(command).values.first.to_i.positive?
    end

    def sanitize_string(str)
      str.delete("$").strip
    end

    def extract_parts(command)
      sanitize_string(command).split(" ")
    end

    def extract_file(command)
      parts = extract_parts(command)

      Hash[
        parts.last.to_s => parts.first.to_i
      ]
    end

    def filename!(hash, key)
      hash[key] = hash.key?(key) ? hash[key] + 1 : 1
      return unless hash[key] > 1

      key += "-#{hash[key]}"
    end

    def init_file(key)
      Hash[
        key => Hash[
          parent_directory: nil,
        ]
      ]
    end

    def parent_directory!(file_hash, idx)
      ctr = 1
      while file_hash[:parent_directory].nil? do
        command = sanitize_string(@lines[idx - ctr])
        ctr += 1
        if command == "ls"
          command = sanitize_string(@lines[idx - ctr])
          file_hash[:parent_directory] = command.split(" ").last.to_s
        end
      end
    end

    def group_by(files: @files, hash_key: :parent_directory)
      files.group_by { |_key, val| val[hash_key] }.transform_values(&:flatten)
    end

    def extract_files_by_max_size(files: @files)
      within_max_size = Hash.new
      files.each do |key, val|
        new_val = val.clone
        new_val = Hash[*new_val] unless new_val.is_a?(Hash)
        next if new_val[:size].to_i > @max_size

        within_max_size.merge!(key => new_val)
      end
      within_max_size
    end

    def content_to_hash!(grouped)
      grouped.each do |key, val|
        val_h = val.each_slice(2).to_h
        grouped[key] = Hash.new unless grouped[key].is_a?(Hash)
        group_h = grouped[key]
        group_h[:files] = val_h.map { |k, v| [k, v[:size]] }.to_h
        group_h[:size] = group_h[:files].values.sum
      end
    end

    def percent_up?(num, percent: 90)
      percentage = (num.to_f / @max_size.to_f) * 100
      percentage.to_i > percent
    end

  end
end
