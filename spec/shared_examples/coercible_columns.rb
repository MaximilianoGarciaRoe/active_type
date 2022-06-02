shared_examples_for 'a coercible string column' do |column|

  it 'is nil by default' do
    expect(subject.send(column)).to be_nil
  end

  it 'leaves strings alone' do
    subject.send(:"#{column}=", "string")

    expect(subject.send(column)).to eq("string")
  end

  it 'does not convert blank' do
    subject.send(:"#{column}=", "")

    expect(subject.send(column)).to eq("")
  end

end


shared_examples_for 'a coercible integer column' do |column|

  it 'is nil by default' do
    expect(subject.send(column)).to be_nil
  end

  it 'leaves integers alone' do
    subject.send(:"#{column}=", 10)

    expect(subject.send(column)).to eq(10)
  end

  it 'converts strings to integers' do
    subject.send(:"#{column}=", "10")

    expect(subject.send(column)).to eq(10)
  end

  it 'converts blank to nil' do
    subject.send(:"#{column}=", "")

    expect(subject.send(column)).to be_nil
  end

end


shared_examples_for 'a coercible date column' do |column|

  it 'is nil by default' do
    expect(subject.send(column)).to be_nil
  end

  it 'leaves dates alone' do
    date = Date.today
    subject.send(:"#{column}=", date)

    expect(subject.send(column)).to eq(date)
  end

  it 'converts strings to dates' do
    subject.send(:"#{column}=", "2010-10-01")

    expect(subject.send(column)).to eq(Date.new(2010, 10, 1))
  end

  it 'converts blank to nil' do
    subject.send(:"#{column}=", "")

    expect(subject.send(column)).to be_nil
  end

end


shared_examples_for 'a coercible time column' do |column|

  around do |example|
    begin
      old_time_zone = Time.zone
      old_time_zone_aware_attributes = ActiveRecord::Base.time_zone_aware_attributes
      old_default_timezone = ActiveRecord.version_agnostic_default_timezone
      example.run
    ensure
      Time.zone = old_time_zone
      ActiveRecord::Base.time_zone_aware_attributes = old_time_zone_aware_attributes
      ActiveRecord.version_agnostic_default_timezone = old_default_timezone
      subject.class.reset_column_information
    end
  end

  def it_should_convert_like_active_record(column, time)
    subject.class.reset_column_information

    record_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'records'
    end

    comparison = record_class.new
    subject.send(:"#{column}=", time)
    comparison.persisted_time = time

    result = subject.send(column)
    expect(result).to eq(comparison.persisted_time)
    expect(result.zone).to eq(comparison.persisted_time.zone)
  end


  it 'is nil by default' do
    expect(subject.send(column)).to be_nil
  end

  it 'leaves times alone' do
    time = Time.at(Time.now.to_i)
    subject.send(:"#{column}=", time)

    expect(subject.send(column)).to eq(time)
  end

  it 'converts strings to times' do
    subject.send(:"#{column}=", "2010-10-01 12:15")

    expect(subject.send(column)).to eq(Time.local(2010, 10, 1, 12, 15))
  end


  [
    "2010-10-01 12:15",
    "2010-10-01 12:16+03:00",
    "2010-10-01 12:17-01:00",
    "2010-10-01 12:18Z",
    Time.new(2010, 10, 1, 12, 19),
    Time.new(2010, 10, 1, 12, 20).in_time_zone('Paris'),
  ].each do |time|

    it "converts '#{time}' the same as ActiveRecord" do
      Time.zone = 'Hawaii'

      it_should_convert_like_active_record(column, time)
    end

    it "converts '#{time}' the same as ActiveRecord if time_zone_aware_attributes is set" do
      Time.zone = 'Hawaii'
      ActiveRecord::Base.time_zone_aware_attributes = true

      it_should_convert_like_active_record(column, time)
    end

    it "converts '#{time}' the same as ActiveRecord if default_timezone is :utc" do
      Time.zone = 'Hawaii'
      ActiveRecord.version_agnostic_default_timezone = :utc

      it_should_convert_like_active_record(column, time)
    end

    it "converts '#{time}' the same as ActiveRecord if time_zone_aware_attributes is set, default_timezone is :utc" do
      Time.zone = 'Hawaii'
      ActiveRecord.version_agnostic_default_timezone = :utc
      ActiveRecord::Base.time_zone_aware_attributes = true

      it_should_convert_like_active_record(column, time)
    end

  end

end


shared_examples_for 'a coercible boolean column' do |column|

  it 'is nil by default' do
    expect(subject.send(column)).to be_nil
  end

  it 'leaves booleans alone' do
    subject.send(:"#{column}=", true)

    expect(subject.send(column)).to eq(true)
  end

  it 'converts 1 to true' do
    subject.send(:"#{column}=", "1")

    expect(subject.send(column)).to eq(true)
  end

  it 'converts 0 to false' do
    subject.send(:"#{column}=", "0")

    expect(subject.send(column)).to eq(false)
  end

  it 'converts "" to nil' do
    subject.send(:"#{column}=", "")

    expect(subject.send(column)).to be_nil
  end

  it 'converts "true" to true' do
    subject.send(:"#{column}=", "true")

    expect(subject.send(column)).to eq(true)
  end

  it 'converts "false" to false' do
    subject.send(:"#{column}=", "false")

    expect(subject.send(column)).to eq(false)
  end

end

shared_examples_for 'an untyped column' do |column|
  it 'is nil by default' do
    expect(subject.send(column)).to be_nil
  end

  it 'leaves strings alone' do
    subject.send(:"#{column}=", "string")

    expect(subject.send(column)).to eq("string")
  end

  it 'leaves integers alone' do
    subject.send(:"#{column}=", 17)

    expect(subject.send(column)).to eq(17)
  end

  it 'leaves objects alone' do
    object = Object.new
    subject.send(:"#{column}=", object)

    expect(subject.send(column)).to eq(object)
  end
end


shared_examples_for 'a coercible type column' do |column, type|

  if type

    it 'is nil by default' do
      expect(subject.send(column)).to be_nil
    end

    it 'leaves strings alone' do
      expect(type).to receive(:cast).with('input').and_return('output')
      subject.send(:"#{column}=", 'input')

      expect(subject.send(column)).to eq('output')
    end

  end

end
