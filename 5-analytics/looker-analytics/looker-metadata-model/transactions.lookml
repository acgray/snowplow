
- view: transactions
  derived_table:
    sql: |
      SELECT 
        domain_userid,
        domain_sessionidx,
        tr_orderid,
        tr_affiliation,
        tr_total,
        tr_tax,
        tr_city,
        tr_state,
        tr_country,
        MIN(collector_tstamp) AS tr_tstamp
      FROM atomic.events 
      WHERE event = 'transaction'
      GROUP BY 1,2,3,4,5,5,6,7,8,9
      ORDER BY tr_orderid
    
    persist_for: 3 hours
    
  fields:
  
  # DIMENSIONS #
  
  - dimension: domain_userid
    sql: ${TABLE}.domain_userid
    hidden: true
    
  - dimension: domain_sessionidx
    type: int
    sql: ${TABLE}.domain_sessionidx
    hidden: true
    
  # Transaction fields #
  
  - dimension: order_id
    primary_key: true
    sql: ${TABLE}.tr_orderid
    
  - dimension: affiliation
    sql: ${TABLE}.tr_affiliation
    
  - dimension: transaction_value
    type: number
    decimals: 2
    sql: ${TABLE}.tr_total
    
  - dimension: tax
    type: number
    decimals: 2
    sql: ${TABLE}.tr_tax
    
  - dimension: city
    sql: ${TABLE}.tr_city
    
  - dimension: state
    sql: ${TABLE}.tr_state
    
  - dimension: country
    sql: ${TABLE}.tr_country
    
  - dimension_group: occurred
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.tr_tstamp
    
  - dimension: order_items
    sql: ${order_id}
    html: |
      <a href=transaction_items?fields=transaction_items.transaction_items_detail*&f[transaction_items.order_id]=<%= value%>>Transaction Items</a>
  
    

  # Measures #
  
  - measure: transactions_count
    type: count_distinct
    sql: ${order_id}
    detail: transaction_detail*
    
  - measure: transactions_value
    type: sum
    sql: ${transaction_value}

  # ----- Detail ------
  sets:
    transaction_detail:
      - order_id
      - occurred_time
      - domain_userid
      - domain_sessionidx
      - transaction_value
      - city
      - state
      - country
      - order_items