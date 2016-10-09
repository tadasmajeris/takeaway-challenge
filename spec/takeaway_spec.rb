require 'takeaway'

describe Takeaway do

  let(:filename) { 'menu.csv' }
  let(:dish_list) { DishList.new(Dish) }
  let(:order) { Order.new }
  subject { described_class.new(dish_list: dish_list, order: order) }

  describe 'initialization' do
    it 'can be initialized with a new dish list' do
      expect(subject.dish_list).to eq dish_list
    end
    it 'can be initialized with a new order' do
      expect(subject.order).to eq order
    end
  end

  describe '#load_dishes' do
    let (:false_filename) { 'some.csv' }

    it 'should check if file exists' do
      expect(File).to receive(:exist?).with(filename)
      subject.load_dishes(filename)
    end

    it 'should return error message when file doesnt exist' do
      allow(File).to receive(:exist?).with(false_filename).and_return false
      expect(subject.load_dishes(false_filename)).to eq "File '#{false_filename}' not found!"
    end

    it 'should try to read the CSV data' do
      expect(CSV).to receive(:foreach).with(filename)
      subject.load_dishes(filename)
    end

    it 'should add dishes to the dish list' do
      expect {subject.load_dishes(filename)}.to change{dish_list.dishes.count}
    end
  end

  context 'when we have some items loaded' do
    before { subject.load_dishes(filename) }

    describe '#menu' do
      it 'should print the menu on the screen' do
        expect(STDOUT).to receive(:puts).with(dish_list)
        subject.menu
      end
    end


    let(:id) { 1 }
    let(:out_id) { dish_list.dishes.count + 1 }

    describe '#add_dish' do
      it 'should add the selected dish to the order' do
        expect {subject.add_dish(id)}.to change{order.items.count}.by(1)
      end

      it 'should raise error when id is out of range of available dishes' do
        expect { subject.add_dish(out_id) }.to raise_error "Wrong ID! Please, select dishes from 1 to #{dish_list.dishes.count}"
      end

      it 'should raise error when quantity is <1' do
        expect { subject.add_dish(id, 0) }.to raise_error "Wrong quantity! Quantity should be 1 or more"
      end
    end

    describe '#remove_dish' do
      it 'should remove the selected dish from the order' do
        subject.add_dish(id)
        expect {subject.remove_dish(id)}.to change{subject.order.items.count}.by(-1)
      end

      it 'should raise error when id is out of range of available dishes' do
        expect { subject.remove_dish(out_id) }.to raise_error "Wrong ID! Please, select dishes from 1 to #{dish_list.dishes.count}"
      end

      it 'should raise error when quantity is <1' do
        expect { subject.remove_dish(id, 0) }.to raise_error "Wrong quantity! Quantity should be 1 or more"
      end
    end

    describe '#order_total' do
      it 'should get the sum total of the order' do
        expect(order).to receive(:total)
        subject.order_total
      end
    end
  end
end
