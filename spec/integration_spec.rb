require "spec_helper"
require "./spec/fixtures/fake_worker"

def maybe_cleanup_file(file_path)
  File.delete(file_path) if File.exist?(file_path)
end

RSpec.describe "Sidekiq integration" do
  before do
    maybe_cleanup_file(FakeWorker::JOB_RUN_PATH)
    maybe_cleanup_file(FakeWorker::JOB_SUCCESS_PATH)
    maybe_cleanup_file(FakeWorker::JOB_FAILURE_PATH)
    maybe_cleanup_file(FakeWorker::JOB_LOCK_FAILURE_PATH)
    maybe_cleanup_file(FakeWorker::JOB_BEFORE_START_PATH)
    maybe_cleanup_file(FakeWorker::SCHEDULE_COLLISION_PATH)
  end

  it "should start sidekiq, schedule FakeWorker, and verify that it ran" do
    path = File.expand_path(File.dirname(__FILE__)) + "/fixtures/env.rb"
    pid = Process.spawn "bundle exec sidekiq -r #{path}"
    puts "Spawned process #{pid}"
    timeout = 30
    start = Time.new
    while (Time.new - start) < timeout
      break if File.exist?(FakeWorker::JOB_RUN_PATH)
      sleep 0.5
    end
    Process.kill("INT", pid)
    Process.wait(pid, 0)
    expect(File).to exist(FakeWorker::JOB_RUN_PATH)
  end
end
