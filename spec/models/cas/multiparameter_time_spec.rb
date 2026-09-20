require 'rails_helper'

RSpec.describe Cas::MultiparameterTime do
  def time_from(parts, current: nil)
    described_class.new(parts, current: current).to_time
  end

  it 'builds midnight from a full date pick' do
    expect(time_from(1 => 2010, 2 => 3, 3 => 7)).to eq Time.zone.local(2010, 3, 7)
  end

  # A date select with a blank option submits nil for the parts left blank.
  # Rails hands the setter nil when every part is blank, but a half-picked
  # date arrives with some parts nil, and that is not a date.
  it 'is nil when any date part is missing' do
    expect(time_from(1 => 2010, 2 => nil, 3 => nil)).to be_nil
    expect(time_from(1 => nil, 2 => 3, 3 => 7)).to be_nil
  end
end
