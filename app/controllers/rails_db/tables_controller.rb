module RailsDb
  class TablesController < RailsDb::ApplicationController
    if Rails::VERSION::MAJOR >= 4
      before_action :find_table, only: [:show, :data, :csv, :truncate, :destroy, :edit, :update, :xlsx]
    else
      before_filter :find_table
    end

    def index
      @tables = RailsDb::Database.accessible_tables
    end

    def show
    end

    def data
      session[:per_page] = per_page
      @table  = @table.paginate page: params[:page],
                                sort_column: params[:sort_column],
                                sort_order: params[:sort_order],
                                per_page: per_page
    end

    def csv
      send_data(@table.to_csv, type: 'text/csv; charset=utf-8; header=present', filename: "#{@table.name}.csv")
    end

    def xlsx
      render xlsx: 'table', filename: "#{@table.name}.xlsx"
    end

    def truncate
      @table.truncate
      render :data
    end

    def destroy
      @table = @table.paginate page: params[:page],
                               sort_column: params[:sort_column],
                               sort_order: params[:sort_order],
                               per_page: per_page
      @table.delete(params[:pk_id])
      respond_to do |page|
        page.html { redirect_to action: :data, table_id: params[:table_id] }
        page.js {}
      end
    end

    def edit
      @record = @table.as_model.find(params[:pk_id])
      respond_to do |page|
        page.html { redirect_to action: :data, table_id: params[:table_id] }
        page.js {}
      end
    end

    def update
      @record = @table.as_model.find(params[:pk_id])
      @record.update_attributes(record_attributes)
      respond_to do |page|
        page.html { redirect_to action: :data, table_id: params[:table_id] }
        page.js {}
      end
    end

    private

    def record_attributes
      if Rails::VERSION::MAJOR >= 4
        params[:record].permit!
      else
        params[:record]
      end
    end

    def find_table
      @table ||= RailsDb::Table.new(params[:id] || params[:table_id])
    end

    def per_page
      params[:per_page] || session[:per_page]
    end

  end
end