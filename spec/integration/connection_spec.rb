require File.expand_path('spec_helper', File.dirname(__FILE__) + '/../')

describe EMMongo::Connection do
  include EM::Spec

  it 'should connect' do
    @conn = EMMongo::Connection.new
    EM.add_timer(0.1) do
      @conn.should be_connected
      done
    end
  end

  it 'should close' do
    @conn = EMMongo::Connection.new

    EM.add_timer(0.1) do
      @conn.should be_connected
      @conn.close
    end

    EM.add_timer(0.2) do
      EM.next_tick do
        @conn.should_not be_connected
        done
      end
    end
  end

  it 'should reconnect' do
    @conn = EMMongo::Connection.new(EM::Mongo::DEFAULT_IP, EM::Mongo::DEFAULT_PORT, nil, {:reconnect_in => 0.5})
    EM.add_timer(0.1) do
      @conn.close
    end
    EM.add_timer(0.9) do
      @conn.should be_connected
      done
    end
  end

  it 'should instantiate a Database' do
    @conn = EMMongo::Connection.new

    db1 = @conn.db
    db1.should be_kind_of(EM::Mongo::Database)

    db2 = @conn.db('db2')
    db2.should be_kind_of(EM::Mongo::Database)
    db2.should_not == db1

    done
  end

  it 'should set query options' do
    @conn = EMMongo::Connection.new
    em_conn = @conn.db.connection

    options = {
      :tailable_cursor   => true, # bit 1
      :slave_ok          => true, # bit 2
      :no_cursor_timeout => true, # bit 4
      :await_data        => true, # bit 5
      :exhaust           => true  # bit 6
    }
    em_conn.op_query_bitvector(options).should == 0b1110110
    em_conn.op_query_bitvector({}).should == 0

    done
  end


end
