require '05_lockable'

describe 'Lockable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Cat < SQLObject
      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      finalize!
    end
  end

  it '#is_lockable? returns false if an object cannot be locked' do
    cat = Cat

    expect(cat.is_lockable?).to eq(false)
  end

  it '#is_lockable? returns true if an object can be locked' do
    human = Human

    expect(human.is_lockable?).to eq(true)
  end

  it '#is_locked? raises error if lock_version changes before updating' do
    human1 = Human.find(1)
    human2 = Human.find(1)

    human1.fname = "Bob"
    human1.update

    human2.fname = "Bill"
    expect { human2.update }.to raise_error("ActivateRecord::StaleObject")
  end

  it '#update increments lock_version' do
    human1 = Human.find(1)
    human1.fname = "Bob"
    human1.update

    expect(Human.find(1).lock_version).to eq(2)
  end

end
