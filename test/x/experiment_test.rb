require "test_helper"

module X
  class ButtonExperiment
    include X::Experiment

    variant "green_button"
    variant "blue_button"
    variant "pink_button"

    def initialize(user_id)
      @user_id = user_id
    end

    def unit
      @user_id
    end
  end

  class ExperimentTest < Minitest::Test
    def setup
      @user_id    = 123
      @experiment = ButtonExperiment.new(@user_id)
    end

    def test_requires_variants_to_be_defined
      obj = Object.new
      obj.extend X::Experiment

      assert_raises VariantsMissingError do
        obj.run
      end
    end

    def test_default_exposure
      assert_equal 1.0, @experiment.exposure
    end

    def test_exposure
      assert_equal true, @experiment.exposed?
    end

    def test_changing_exposure
      @experiment.stub :exposure, 0 do
        assert_equal false, @experiment.exposed?
      end
    end

    def test_assignment
      assert_equal "green_button", @experiment.assignment
    end

    def test_assignment_when_experiment_is_disabled
      @experiment.stub :enabled?, false do
        assert_equal nil, @experiment.assignment
      end
    end

    def test_assignment_as_exposure_changes
      @experiment.stub :exposure, 0 do
        assert_equal false, @experiment.exposed?
        assert_equal nil, @experiment.assignment
      end

      @experiment.stub :exposure, 0.5 do
        assert_equal false, @experiment.exposed?
        assert_equal nil, @experiment.assignment
      end

      assert_equal true, @experiment.exposed?
      assert_equal "green_button", @experiment.assignment
    end

    def test_assignment_is_consistent_as_exposure_changes
      @experiment.stub :exposure, 0.9 do
        assert_equal true, @experiment.exposed?
        assert_equal "green_button", @experiment.assignment
      end

      @experiment.stub :exposure, 0.95 do
        assert_equal true, @experiment.exposed?
        assert_equal "green_button", @experiment.assignment
      end

      assert_equal true, @experiment.exposed?
      assert_equal "green_button", @experiment.assignment
    end

    def test_variants_assigned_uniformly
      result = {"green_button" => 0, "blue_button" => 0, "pink_button" => 0}

      30_000.times do |x|
        user_id = SecureRandom.random_number(1_000_000)
        variant = ButtonExperiment.new(user_id).assignment
        result[variant] += 1
      end

      assert_in_delta 10000, result["green_button"], 300
      assert_in_delta 10000, result["blue_button"], 300
      assert_in_delta 10000, result["pink_button"], 300
    end
  end
end
