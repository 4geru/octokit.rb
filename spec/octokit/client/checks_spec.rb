# frozen_string_literal: true

require 'helper'

describe Octokit::Client::Checks, :vcr do
  before do
    Octokit.reset!
    @client = oauth_client

    @path = "README.md"
    @commit = "e1db7418a77db065d1900e579c82ef0aad1da2b1"
    @branch = "master" # Equivalent to @commit
    @tag = "v1.0" # Equivalent to @commit
    @check_suite_id = 50440400
    @check_name = "octokit-test-check"
    @check_run_id = 51295429
  end

  describe ".create_check_run" do
    it "creates a check run" do
      @client.create_check_run(
        @test_repo,
        @check_name,
        @commit,
        accept: preview_header,
      )

      assert_requested :post, repo_url("check-runs")
    end

    it "returns the check run" do
      check_run = @client.create_check_run(
        @test_repo,
        @check_name,
        @commit,
        accept: preview_header,
      )

      expect(check_run.name).to eq(@check_name)
      expect(check_run.head_sha).to eq(@commit)
      expect(check_run.status).to eq("queued")
    end
  end

  describe ".update_check_run" do
    it "updates the check run" do
      @client.update_check_run(
        @test_repo,
        @check_run_id,
        accept: preview_header,
        completed_at: "2019-01-17T14:52:51Z",
        conclusion: "success",
        output: {
          annotations: [
            {
              annotation_level: "notice",
              end_line: 1,
              message: "Looks good!",
              path: @path,
              start_line: 1,
            },
          ],
          summary: "Everything checks out.",
          title: "Octokit Check",
        },
      )

      assert_requested :patch, repo_url("check-runs/#{@check_run_id}")
    end

    it "returns the check run" do
      check_run = @client.update_check_run(
        @test_repo,
        @check_run_id,
        accept: preview_header,
        completed_at: "2019-01-17T14:52:51Z",
        conclusion: "success",
        output: {
          annotations: [
            {
              annotation_level: "notice",
              end_line: 1,
              message: "Looks good!",
              path: @path,
              start_line: 1,
            },
          ],
          summary: "Everything checks out.",
          title: "Octokit Check",
        },
      )

      expect(check_run.id).to eq(@check_run_id)
      expect(check_run.status).to eq("completed")
    end
  end

  describe ".check_runs_for_ref" do
    it "returns check runs for a commit" do
      result = @client.check_runs_for_ref(
        @test_repo,
        @commit,
        accept: preview_header,
      )

      expect(result.total_count).to eq(1)
      expect(result.check_runs).to be_a(Array)
      expect(result.check_runs.count).to eq(1)
      expect(result.check_runs[0].id).to eq(@check_run_id)
    end

    it "returns check runs for a branch" do
      result = @client.check_runs_for_ref(
        @test_repo,
        @branch,
        accept: preview_header,
      )

      expect(result.total_count).to eq(1)
      expect(result.check_runs).to be_a(Array)
      expect(result.check_runs.count).to eq(1)
      expect(result.check_runs[0].id).to eq(@check_run_id)
    end

    it "returns check runs for a tag" do
      result = @client.check_runs_for_ref(
        @test_repo,
        @tag,
        accept: preview_header,
      )

      expect(result.total_count).to eq(1)
      expect(result.check_runs).to be_a(Array)
      expect(result.check_runs.count).to eq(1)
      expect(result.check_runs[0].id).to eq(@check_run_id)
    end

    it "filters by status" do
      result = @client.check_runs_for_ref(
        @test_repo,
        @commit,
        accept: preview_header,
        status: "completed",
      )

      expect(result.total_count).to eq(0)
      expect(result.check_runs).to be_a(Array)
      expect(result.check_runs.count).to eq(0)

      result = @client.check_runs_for_ref(
        @test_repo,
        @commit,
        accept: preview_header,
        status: "queued",
      )

      expect(result.total_count).to eq(1)
      expect(result.check_runs).to be_a(Array)
      expect(result.check_runs.count).to eq(1)
      expect(result.check_runs[0].id).to eq(@check_run_id)
    end
  end

  describe ".check_runs_for_check_suite" do
    it "returns check runs for a check suite" do
      result = @client.check_runs_for_check_suite(
        @test_repo,
        @check_suite_id,
        accept: preview_header,
      )

      expect(result.total_count).to eq(1)
      expect(result.check_runs).to be_a(Array)
      expect(result.check_runs.count).to eq(1)
      expect(result.check_runs[0].id).to eq(@check_run_id)
    end

    it "filters by status" do
      result = @client.check_runs_for_check_suite(
        @test_repo,
        @check_suite_id,
        accept: preview_header,
        status: "completed",
      )

      expect(result.total_count).to eq(0)
      expect(result.check_runs).to be_a(Array)
      expect(result.check_runs.count).to eq(0)

      result = @client.check_runs_for_check_suite(
        @test_repo,
        @check_suite_id,
        accept: preview_header,
        status: "queued",
      )

      expect(result.total_count).to eq(1)
      expect(result.check_runs).to be_a(Array)
      expect(result.check_runs.count).to eq(1)
      expect(result.check_runs[0].id).to eq(@check_run_id)
    end
  end

  describe ".check_run" do
    it "returns the check run" do
      check_run = @client.check_run(
        @test_repo,
        @check_run_id,
        accept: preview_header,
      )

      expect(check_run.id).to eq(@check_run_id)
      expect(check_run.name).to eq(@check_name)
      expect(check_run.head_sha).to eq(@commit)
    end
  end

  describe ".check_run_annotations" do
    it "returns annotations for the check run" do
      annotations = @client.check_run_annotations(
        @test_repo,
        @check_run_id,
        accept: preview_header,
      )

      expect(annotations).to be_a(Array)
      expect(annotations.count).to eq(1)
      expect(annotations[0].path).to eq(@path)
    end
  end

  describe ".check_suite" do
    it "returns the check suite" do
      check_suite = @client.check_suite(
        @test_repo,
        @check_suite_id,
        accept: preview_header,
      )

      expect(check_suite.id).to eq(@check_suite_id)
      expect(check_suite.head_sha).to eq(@commit)
    end
  end

  describe ".check_suites_for_ref" do
    it "returns check suites for a commit" do
      result = @client.check_suites_for_ref(
        @test_repo,
        @commit,
        accept: preview_header,
      )

      expect(result.total_count).to eq(1)
      expect(result.check_suites).to be_a(Array)
      expect(result.check_suites.count).to eq(1)
      expect(result.check_suites[0].id).to eq(@check_suite_id)
    end

    it "returns check suites for a branch" do
      result = @client.check_suites_for_ref(
        @test_repo,
        @branch,
        accept: preview_header,
      )

      expect(result.total_count).to eq(1)
      expect(result.check_suites).to be_a(Array)
      expect(result.check_suites.count).to eq(1)
      expect(result.check_suites[0].id).to eq(@check_suite_id)
    end

    it "returns check suites for a tag" do
      result = @client.check_suites_for_ref(
        @test_repo,
        @tag,
        accept: preview_header,
      )

      expect(result.total_count).to eq(1)
      expect(result.check_suites).to be_a(Array)
      expect(result.check_suites.count).to eq(1)
      expect(result.check_suites[0].id).to eq(@check_suite_id)
    end

    it "filters by check name" do
      result = @client.check_suites_for_ref(
        @test_repo,
        @commit,
        accept: preview_header,
        check_name: "bogus-check-name",
      )

      expect(result.total_count).to eq(0)
      expect(result.check_suites).to be_a(Array)
      expect(result.check_suites.count).to eq(0)

      result = @client.check_suites_for_ref(
        @test_repo,
        @commit,
        accept: preview_header,
        check_name: @check_name,
      )

      expect(result.total_count).to eq(1)
      expect(result.check_suites).to be_a(Array)
      expect(result.check_suites.count).to eq(1)
      expect(result.check_suites[0].id).to eq(@check_suite_id)
    end
  end

  describe ".set_check_suite_preferences" do
    it "sets check suite preferences" do
      @client.set_check_suite_preferences(
        @test_repo,
        accept: preview_header,
        auto_trigger_checks: [
          {
            app_id: test_github_integration,
            setting: false,
          },
        ],
      )

      assert_requested :patch, repo_url("check-suites/preferences")
    end
  end

  describe ".create_check_suite" do
    it "creates a check suite" do
      @client.create_check_suite(
        @test_repo,
        @commit,
        accept: preview_header,
      )

      assert_requested :post, repo_url("check-suites")
    end

    it "returns the check suite" do
      check_suite = @client.create_check_suite(
        @test_repo,
        @commit,
        accept: preview_header,
      )

      expect(check_suite.head_sha).to eq(@commit)
      expect(check_suite.status).to eq("queued")
    end
  end

  describe ".rerequest_check_suite" do
    it "requests the check suite again" do
      @client.rerequest_check_suite(
        @test_repo,
        @check_suite_id,
        accept: preview_header,
      )

      assert_requested :post, repo_url("check-suites/#{@check_suite_id}/rerequest")
    end
  end

  private

  def preview_header
    Octokit::Preview::PREVIEW_TYPES[:checks]
  end

  def repo_url(repo_path)
    github_url(["repos", @test_repo, repo_path].join("/"))
  end
end
