class Finder
  require 'nokogiri'
  require 'open-uri'
  require 'kconv'
  attr_accessor :f_from,:f_to,:time_required,:d_time,:platform_number,:platform_name,:a_time,:price,:bording_number,:next_bus_url,:prev_bus_url
  def initialize(f_date_year,f_date_month,f_date_day,f_hour,f_min,f_from,f_to,url)
    @url= url.nil? ? set_default_url(f_date_year,f_date_month,f_date_day,f_hour,f_min,f_from,f_to) : url
    @charset=nil
    @f_from=f_from
    @f_to=f_to
    @html=get_html()
    @nokogiri=get_nokogiri()
    @time_required,@d_time,@platform_number,@platform_name,@a_time,@price=get_nokogiri_tr1
    @bording_number=get_bording_number(@platform_number)
    @prev_bus_url=get_prev_bus_url
    @next_bus_url=get_next_bus_url
  end
  private
  def set_default_url(f_date_year,f_date_month,f_date_day,f_hour,f_min,f_from,f_to)
    URI.encode("http://kantobus.info/route/result/?action_route_result=1&f_from_type=1&f_to_type=1&f_from_genre=&f_to_genre=&f_from="+f_from+"&f_to="+f_to+"&f_through=&fs_from=1&fs_to=32&f_type_fromto=1&f_date_Year="+f_date_year.to_s+"&f_date_Month="+f_date_month.to_s+"&f_date_Day="+f_date_day.to_s+"&f_hour="+f_hour.to_s+"&f_min="+f_min.to_s+"&f_wait=10&action_route_result.x=168&action_route_result.y=18&action_route_result=経路・運賃を表示")
  end
  def get_html
    target_css='title'
    html = open(@url) do |f|
      @charset=f.charset
      f.read # htmlを読み込んで変数htmlに渡す
    end
    return html
  end
  def get_nokogiri
    return Nokogiri::HTML.parse(@html, nil, @charset)
  end
  def get_platform
    return @nokogiri.search("tr")[1].text.gsub(/\n\t*/,",").gsub(/,+/,",").split(/,/)[3].split(/ /)[0]
  end
  def get_nokogiri_tr1
    tr1= @nokogiri.search("tr")[1].text.gsub(/\n\t*/,",").gsub(/,+/,",").split(/,/)
    return [tr1[1],tr1[2],tr1[3].split(/ /)[0],tr1[3].split(/ /)[1],tr1[7],tr1[8]]
  end
  def get_bording_number(platform_number)
    return Platform.where(name: platform_number).pluck(:bording_number).join(",")
  end
  def get_prev_bus_url
    return "http://kantobus.info"+@nokogiri.css("a.route_time_transition_prev")[0].attributes["href"].value
  end
  def get_next_bus_url
    return "http://kantobus.info"+@nokogiri.css("a.route_time_transition_next")[0].attributes["href"].value
  end
end