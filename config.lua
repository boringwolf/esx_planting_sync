Config = {}
Config.Locale = "zh_TW"
--You can add here buttons like inventory menu button. When player click this button, then action will be cancel.
Config.cancel_buttons = {289, 170, 168, 56}

options =
{
  ['seed_weed'] = {
        name = 'seed_weed',
        object = 'prop_weed_01',
        end_object = 'prop_weed_02',
        fail_msg = '不幸的是，植物已經枯萎了!',
        success_msg = '恭喜，收成前的等待是值得的!',
        start_msg = '開始種植.',
        progess_msg = '大麻種植中',
        progess_end_msg = '大麻最終階段',
        success_item = 'weed',
        cops = 0,
        first_step = 2.35,
        steps = 6,
        cords = {
          {x = -427.05, y = 1575.25, z = 357, distance = 20.25},
          {x = 2213.05, y = 5576.25, z = 53, distance = 10.25},
          {x = 1198.05, y = -215.25, z = 55, distance = 20.25},
          {x = 706.05, y = 1269.25, z = 358, distance = 10.25},
        },
        animations_start = {
          {lib = 'amb@world_human_gardener_plant@male@enter', anim = 'enter', timeout = '2500'},
          {lib = 'amb@world_human_gardener_plant@male@idle_a', anim = 'idle_a', timeout = '2500'},
        },
        animations_end = {
          {lib = 'amb@world_human_gardener_plant@male@exit', anim ='exit', timeout = '2500'},
          {lib = 'amb@world_human_cop_idles@male@idle_a', anim ='idle_a', timeout = '2500'},
        },
        animations_step = {
          {lib = 'amb@world_human_gardener_plant@male@enter', anim = 'enter', timeout = '2500'},
          {lib = 'amb@world_human_gardener_plant@male@idle_a', anim ='idle_a', timeout = '18500'},
          {lib = 'amb@world_human_gardener_plant@male@exit', anim ='exit', timeout = '2500'},
        },
        grow = {
          1.95, 1.65, 1.45, 1.20, 1.00
        }
      },
}
