require 'spec_helper'
require 'appraisal/gemfile'
require 'active_support/core_ext/string/strip'

describe Appraisal::Gemfile do
  include StreamHelpers

  it "supports gemfiles without sources" do
    gemfile = Appraisal::Gemfile.new
    expect(gemfile.to_s.strip).to eq ''
  end

  it "supports multiple sources" do
    gemfile = Appraisal::Gemfile.new
    gemfile.source "one"
    gemfile.source "two"
    expect(gemfile.to_s.strip).to eq %{source "one"\nsource "two"}
  end

  it "preserves dependency order" do
    gemfile = Appraisal::Gemfile.new
    gemfile.gem "one"
    gemfile.gem "two"
    gemfile.gem "three"
    expect(gemfile.to_s).to match(/one.*two.*three/m)
  end

  it "supports symbol sources" do
    gemfile = Appraisal::Gemfile.new
    gemfile.source :one
    expect(gemfile.to_s.strip).to eq %{source :one}
  end

  it 'supports group syntax' do
    gemfile = Appraisal::Gemfile.new

    gemfile.group :development, :test do
      gem "one"
    end

    expect(gemfile.to_s).to eq <<-GEMFILE.strip_heredoc.strip
      group :development, :test do
        gem "one"
      end
    GEMFILE
  end

  it 'supports groups syntax, but with deprecation warning' do
    gemfile = Appraisal::Gemfile.new

    warning = capture(:stderr) do
      gemfile.groups :development, :test do
        gem "one"
      end
    end

    expect(gemfile.to_s).to eq <<-GEMFILE.strip_heredoc.strip
      group :development, :test do
        gem "one"
      end
    GEMFILE

    expect(warning).to match(/deprecated/)
  end

  it 'supports platform syntax' do
    gemfile = Appraisal::Gemfile.new

    gemfile.platform :jruby do
      gem "one"
    end

    expect(gemfile.to_s).to eq <<-GEMFILE.strip_heredoc.strip
      platforms :jruby do
        gem "one"
      end
    GEMFILE
  end

  it 'supports platforms syntax' do
    gemfile = Appraisal::Gemfile.new

    gemfile.platforms :jruby do
      gem "one"
    end

    expect(gemfile.to_s).to eq <<-GEMFILE.strip_heredoc.strip
      platforms :jruby do
        gem "one"
      end
    GEMFILE
  end

  context "excess new line" do
    context "no contents" do
      it "shows empty string" do
        gemfile = Appraisal::Gemfile.new
        expect(gemfile.to_s).to eq ''
      end
    end

    context "full contents" do
      it "does not show newline at end" do
        gemfile = Appraisal::Gemfile.new
        gemfile.source "source"
        gemfile.gem "gem"
        gemfile.gemspec
        expect(gemfile.to_s).to match(/[^\n]\z/m)
      end
    end

    context "no gemspec" do
      it "does not show newline at end" do
        gemfile = Appraisal::Gemfile.new
        gemfile.source "source"
        gemfile.gem "gem"
        expect(gemfile.to_s).to match(/[^\n]\z/m)
      end
    end
  end
end
