require 'open-uri'
require 'nokogiri'
require 'terminal-table'
require 'colorize'



#constant
COMMON_ROOT_XPATH = "/html/body/div/div[3]/div[1]/div[4]/div[2]/div[2]"
OPENWILLEY = "http://onlinelibrary.wiley.com"

###########################################################################################
###########################################################################################
###########################################################################################
class  Issue
  attr_accessor :issue_date, :issue_page, :link_for_article

  def initialize(issue)
    #issues[0] need to be increment
    @issue_date = issue.css("div.details").children[0].text#"December 2012" 
    @issue_page = issue.css("div.details").children[1].text#"Volume 63, Issue 12, Page 2351-2558" 
    #save the link into a variable
    @link_for_article = issue.css("div.details").children[1].children[1].children.first.attributes["href"].value
  end

end

###########################################################################################
class Article
  attr_accessor :access, :title, :author, :doi, :pdf_link, :enhance_article, :full_html, :resume_abstract

  def initialize(articles)
    div_citation = articles.css("div.citation")
      @access = articles.css("div.access").children.first.content
      @title  = div_citation.children[0].text
      @author  = div_citation.children[1].text
      @doi = div_citation.children[2].text.split('|').last
      compteur  =  0
      ##if text.contains "erratum" add  + 1 to compteur (children[3 + compteur])
      unless author.eql?("David J. Solomon and Bo-Christer Björk")
    other_links = div_citation.children[3]
    #puts other_links
      @pdf_link =  OPENWILLEY + other_links.children[3].children[0].attributes['href'].value
      @enhance_article =other_links.children[2].children.first.attributes['href'].value
      article_full_html =  other_links.children[1].children.first.attributes['href'].value
        @full_html = OPENWILLEY + article_full_html
        article_full_abstract = other_links.children[0].children.first.attributes['href'].value
          @resume_abstract = article_full_abstract + OPENWILLEY
      end
  end

end

#######################################################################
#######################################################################
#######################################################################
#######################################################################
def  get_content_of_the_web_page(link)
  doc = Nokogiri::HTML(open(link))
end

##########################################################
#Issue and volume # of the journal
print "Type wich YEAR are you looking for (i.e 2012) ? : "
STDOUT.flush  
year = gets.chomp  

##################### ERROR Validation
valid_year = (1950..Time.now.year).to_a
it_s_valid  = valid_year.include?(year.to_i)

unless it_s_valid
   puts "\n\nError! \n We can only look for Issues between 1950-2014)".upcase.colorize( :background => :red)
   puts "\tyour request was for the year #{year}\n\n".colorize( :background => :red)
   exit!
end
##########


puts "...recherche de la requete un moment svp\n\t pour l'année #{year.to_s}...."
link="http://onlinelibrary.wiley.com/journal/10.1002/(ISSN)2330-1643/issues?year=#{year}"

location_xpath = COMMON_ROOT_XPATH + '/ul/li'
doc = get_content_of_the_web_page(link)
issues = doc.xpath(location_xpath)

#creating Issues for the journal
rows = []
list_of_issue = issues.map { |issue| Issue.new(issue)}
index = 0
list_of_issue.each do |issue|
  rows << [{:value => index.to_s.colorize(:blue), :align => :center}, issue.issue_date, issue.issue_page]
  index = index.next
end

table = Terminal::Table.new :title => "JAIST Issue on #{year}", 
        :headings => ['#', 'date', "page"], 
        :rows => rows


puts table



################################################################
#user interaction
print "Type wich ISSUE are you looking for (1-12) ? : "  
STDOUT.flush  
selection = gets.chomp  


##################### ERROR Validation
valid_issue = (0..list_of_issue.size).to_a
it_s_valid  = valid_issue.include?(selection.to_i)

unless it_s_valid
   puts "\n\nError! \n We can only look for Issues between 0-#{list_of_issue.size})".upcase
   puts "\tyour request was for the issue ##{selection}\n\n"
   exit!
end
##########

puts "for the Issue " + list_of_issue.at(selection.to_i).issue_date
selection = list_of_issue.at(selection.to_i).link_for_article

selection =  OPENWILLEY + selection

=begin 
  What is your Browser ?
    replace %x|firefox #{selection}| with
      %x|google-chrome #{selection}|
      %x|chromium-browser #{selection}|
      %x|opera #{selection}|
      for MAC -- replace the entire line with one of these lines
        %x|open -a Safari #{selection}|
        %x|open -a firefox -g #{selection}|
=end
%x|firefox #{selection}|
exit!

#if null http://onlinelibrary.wiley.com/doi/10.1002/asi.21649/pdf
#than exit


