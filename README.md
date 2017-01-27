# X
### A Ruby toolkit for deterministic experiment assignment and exposure.

Inspired by Facebook's [Planout](https://github.com/facebook/planout).

## Example

```ruby
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

user_id = 12345
ButtonExperiment.new(user_id).assignment
#=> "blue_button"
```

In the above example, `variants` is a list of the possible values we want to return in order to determine what we want to show to users.

The contents of this experiment will be hashed to guarantee any value of `unit` will always return the same variant assignment.

```ruby
user_id = 12345
ButtonExperiment.new(user_id).assignment
#=> "blue_button"

ButtonExperiment.new(user_id).assignment
#=> "blue_button"

ButtonExperiment.new(user_id).assignment
#=> "blue_button"
```

## Weightings

By default, variants will be assigned uniformly. With two variants defined, distribution of assignments should be approximately 50%/50%; with three variants defined, distribution of assignments should be approximately 33%/33%/33%, etc.

Optionally, you can give variants a `weight` parameter:

```ruby
class WeightedButtonExperiment
  include X::Experiment

  variant "green_button", weight: 60
  variant "blue_button", weight: 30
  variant "pink_button", weight: 10 # Weights don't necessarily need to add up 100

  def initialize(user_id)
    @user_id = user_id
  end

  def unit
    @user_id
  end
end

user_id = 54321
WeightedButtonExperiment.new(user_id).assignment
#=> "green_button"
```

## Exposure

Some times, you want to release an experiment to a small subset of users before rolling out to a wider audience. You can control the exposure of variant assignments by setting `exposure` on an experiment.

```ruby
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

  def exposure
    0.1
  end
end

user_id = 1234
exp = ButtonExperiment.new(user_id)
exp.assignment
#=> nil

# You can also check if this `unit` is in the exposure group
exp.exposed?
#=> false

# Override `exposure` via Ruby hackery
exp.define_singleton_method(:exposure) { 0.4 }
exp.assignment
#=> "green_button"
exp.exposed?
#=> true

# Let's turn up the feature to 100% and confirm the assignment stays the same
exp.define_singleton_method(:exposure) { 1.0 }
# Check if this unit is exposed to variant assignment
exp.exposed?
#=> true
exp.assignment
#=> "green_button"
```

So long as the `unit` is in the exposure group, the variant assignment will never change.

## Disabling experiments

To disable an experiment, simply override `enabled?` on your experiment:

```ruby
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

  def enabled?
    false
  end
end

user_id = 12345
exp = ButtonExperiment.new(user_id)
exp.assignment
#=> nil
```

Alternatively, use the `enabled?` method to filter out candidates that shouldn't be assigned to your experiment:

```ruby
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

  # Limit this experiment to users who have never placed an order
  def enabled?
    Order.where(user_id: user_id).count == 0
  end
end
```

## Reporting / Logging

Whenever `assignment` is called, an optional callback is triggered on your experiment. Use this to log data or trigger background jobs.

```ruby
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

  # Data is a hash of the experiment contents
  def on_assignment(data)
    puts data.inspect
  end
end

user_id = 12345
exp = ButtonExperiment.new(user_id)
exp.assignment
# {:name=>"ButtonExperiment", :assignment=>"blue_button", :exposure=>1.0, :unit=>12345, :variants=>["green_button", "blue_button", "pink_button"]}
# => "blue_button"
```
## Examples

Take a look at the examples directory for some ideas for how you can set `X` up in your application.
