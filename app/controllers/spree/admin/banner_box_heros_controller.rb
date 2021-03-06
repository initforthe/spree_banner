module Spree
  module Admin
    class BannerBoxHerosController < ResourceController

      before_action :reset_enabled_heros, only: [:create, :update]

      def index
        respond_with(@collection)
      end
      
      def show
        redirect_to( :action => :edit )
      end
      

      def clone
        @new = @banner_box.duplicate

        if @new.save
          flash.notice = I18n.t('notice_messages.banner_box_cloned')
        else
          flash.notice = I18n.t('notice_messages.banner_box_not_cloned')
        end

        respond_with(@new) { |format| format.html { redirect_to edit_admin_banner_box_url(@new) } }
      end
      
      protected
      def find_resource
        Spree::BannerBoxHero.find(params[:id])
      end
      
      def location_after_save
        admin_banner_box_heros_path
      end
      
      def collection
        return @collection if @collection.present?
        params[:q] ||= {}
        params[:q][:s] ||= "category, position asc"
        
        @search = super.ransack(params[:q])
        @collection = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def reset_enabled_heros
        Spree::BannerBoxHero.joins(:banner_box_location).where(spree_banner_box_locations: { id: params[:banner_box_hero][:banner_box_location_id]}).update_all(:enabled => false)
      end
    end
  end
end
