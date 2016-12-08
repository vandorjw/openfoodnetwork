class OrderCycleOpenCloseJob
  def perform
    order_cycles = recently_opened_order_cycles.all
    recently_opened_order_cycles.update_all(standing_orders_placed_at: Time.now)
    order_cycles.each do |order_cycle|
      Delayed::Job.enqueue(StandingOrderPlacementJob.new(order_cycle))
    end
  end

  private

  def recently_opened_order_cycles
    return @recently_opened_order_cycles unless @recently_opened_order_cycles.nil?
    @recently_opened_order_cycles =
      OrderCycle.active.where(
        'standing_orders_placed_at IS NULL AND (orders_open_at BETWEEN (?) AND (?) OR updated_at BETWEEN (?) AND (?))',
        10.minutes.ago, Time.now, 10.minutes.ago, Time.now
      )
  end
end