require 'spec_helper'

describe SpeedAggregateResult do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }
  let(:aggregate_result) { create(:aggregate_result, user: user) }

end