class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = []
    selection_args = []         #The 'where' clause
    movies_each_rating = Movie.select(:rating).distinct
    needs_redirection = false
    
    if params[ :ratings ] && params[ :ratings ].size>0
      session[ :ratings ] = params[ :ratings ]
    elsif session[ :ratings ]   #Only when we need to fill in the incomplete inputs with session data will we need redirection
      needs_redirection = true
    end
    if params[ :order_by ]
      session[ :order_by ] = params[ :order_by ]
    elsif session[ :order_by ]  #Only when we need to fill in the incomplete inputs with session data will we need redirection
      needs_redirection = true
    end
    
    if session[ :ratings ]==nil
      movies_each_rating.each { |m|
        @all_ratings << {:r => m.rating, :checked => true}
        selection_args << m.rating
      }
    else
      movies_each_rating.each { |m|
        @all_ratings << {:r => m.rating, :checked => session[ :ratings ][ m.rating ]!=nil}
        if session[ :ratings ][ m.rating ]
          selection_args << m.rating
        end
      }
    end

    if session[ :order_by ] == nil
      @movies = Movie.where({rating: selection_args})
      @css_title_class = []
      @css_release_date_class = []
    else
      if session[ :order_by ] == "title"
        @movies = Movie.where({rating: selection_args}).order(:title)
        @css_title_class = [ "hilite" ]
        @css_release_date_class = []
      else
        @movies = Movie.where({rating: selection_args}).order(:release_date)
        @css_title_class = []
        @css_release_date_class = [ "hilite" ]
      end
    end
    
    if needs_redirection
      ratings_and_order_by = {}
      session[ :ratings ].each { |k, v|
        ratings_and_order_by[ "ratings[#{k}]" ] = v
      }
      ratings_and_order_by[ :order_by ] = session[ :order_by ]
      flash.keep(:notice)
      redirect_to movies_path(ratings_and_order_by)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
