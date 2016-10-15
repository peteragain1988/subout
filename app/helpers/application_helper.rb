module ApplicationHelper
	def subout_menu_render

		
		config = {
				'new_oppotunity' => {
					'href' => '/new-opportunity',
					'text' => 'New Opportunity',
					'visible'=> user_signed_in?,
					'class'=>'address'
				},
				'settings' => {
					'href' => '/settings',
					'text' => 'Settings',
					'visible'=> user_signed_in?,
					'class'=>'address'
				},
				'help' => {
					'href' => '/help',
					'text' => 'Help',
					'visible'=> 1,
					'class'=>'address'
				},
				'signin' => {
					'href' => new_user_session_path,
					'text' => 'Sign In',
					'visible'=> !(user_signed_in?),
					'data'=>{
						'method'=>'get'
					}
					
				},
				'signout' => {
					'href' => destroy_user_session_path,
					'text' => 'Sign Out',
					'visible'=> user_signed_in?,
					'data'=>{
						'method'=>'delete'
					}
					
				},
		}
		
		menu = "";
		config.each_pair do |key, item|
			if(item['visible'])			
				menu+=link_to item['text'], item['href'], :data =>item['data'], :class=>item["class"]
			end
		end
			
		return menu
	end
end
