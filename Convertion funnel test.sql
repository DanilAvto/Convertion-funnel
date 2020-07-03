-- step 1: select all the pageviews for relevant sessions
select
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pageview_created_at,
case when pageview_url='/products' then 1 else 0 end as products_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page,
case when pageview_url='/shipping' then 1 else 0 end as shipping_page,
case when pageview_url='/billing' then 1 else 0 end as billing_page,
case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as thank_you_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_pageviews.created_at>'2012-08-05' and 
website_pageviews.created_at<'2012-09-05' 
and utm_source='gsearch'
order by 1,3;

-- create temporary table sessions_level_made_it
select 
website_session_id,
Max(products_page) as products_made_it,
Max(mrfuzzy_page) as mrfuzzy_made_it,
Max(cart_page) as cart_made_it,
Max(shipping_page) as shipping_made_it,
Max(billing_page) as billing_made_it,
Max(thank_you_page) as thank_you_made_it
from(select
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pageview_created_at,
case when pageview_url='/lander-1' then 1 else 0 end as landing_page,
case when pageview_url='/products' then 1 else 0 end as products_page,
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page,
case when pageview_url='/shipping' then 1 else 0 end as shipping_page,
case when pageview_url='/billing' then 1 else 0 end as billing_page,
case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as thank_you_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_pageviews.created_at>'2012-08-05' and 
website_pageviews.created_at<'2012-09-05' 
and utm_source='gsearch'
order by 1,3) as pageview_level
group by 1;

create temporary table clickthrough_rate
select 
Count(distinct website_session_id) as sessions,
Count(distinct case when products_made_it=1 then website_session_id else null end) as to_products,
Count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as to_mr_fuzzy,
Count(distinct case when cart_made_it=1 then website_session_id else null end) as to_cart,
Count(distinct case when shipping_made_it=1 then website_session_id else null end) as to_shipping,
Count(distinct case when billing_made_it=1 then website_session_id else null end) as to_billing,
Count(distinct case when thank_you_made_it=1 then website_session_id else null end) as to_thank_you
from sessions_level_made_it;

select 
Count(distinct case when products_made_it=1 then website_session_id else null end)/Count(distinct website_session_id) as products_clickthrough_rate,
Count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end)/Count(distinct case when products_made_it=1 then website_session_id else null end) as mrfuzzy_clickthrough_rate,
Count(distinct case when cart_made_it=1 then website_session_id else null end)/Count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as cart_clickthrough_rate,
Count(distinct case when shipping_made_it=1 then website_session_id else null end)/Count(distinct case when cart_made_it=1 then website_session_id else null end) as shipping_clickthrough_rate,
Count(distinct case when billing_made_it=1 then website_session_id else null end)/Count(distinct case when shipping_made_it=1 then website_session_id else null end) as billing_clickthrough_rate,
Count(distinct case when thank_you_made_it=1 then website_session_id else null end)/Count(distinct case when billing_made_it=1 then website_session_id else null end) as thank_you_clickthrough_rate
from sessions_level_made_it;