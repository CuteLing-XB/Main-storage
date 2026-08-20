--// iOS26_UI.lua
--// iOS 26 Liquid Glass UI Core


local iOS26_UI = {}


local TweenService =
    game:GetService("TweenService")



------------------------------------------------
-- Theme
------------------------------------------------

iOS26_UI.Theme = {

    Accent =
        Color3.fromRGB(
            0,
            122,
            255
        ),


    Glass =
        Color3.fromRGB(
            255,
            255,
            255
        ),


    Text =
        Color3.fromRGB(
            245,
            245,
            247
        ),


    Off =
        Color3.fromRGB(
            180,
            180,
            185
        )

}



------------------------------------------------
-- Glass Material
------------------------------------------------

function iOS26_UI.CreateGlass(frame)


    frame.BackgroundTransparency =
        0.35


    local corner =
        Instance.new(
            "UICorner"
        )


    corner.CornerRadius =
        UDim.new(
            0,
            18
        )


    corner.Parent =
        frame



    local stroke =
        Instance.new(
            "UIStroke"
        )


    stroke.Color =
        Color3.fromRGB(
            255,
            255,
            255
        )


    stroke.Transparency =
        0.55


    stroke.Parent =
        frame



    return frame

end



------------------------------------------------
-- Toggle
------------------------------------------------

function iOS26_UI.CreateToggle(parent,config)


    config =
        config or {}


    local value =
        config.Default or false



    local toggle =
        Instance.new(
            "TextButton"
        )


    toggle.Name =
        config.Name or "LiquidToggle"


    toggle.Size =
        UDim2.new(
            0,
            54,
            0,
            32
        )


    toggle.Text =
        ""


    toggle.AutoButtonColor =
        false



    toggle.BackgroundColor3 =
        value
        and iOS26_UI.Theme.Accent
        or iOS26_UI.Theme.Off



    toggle.Parent =
        parent



    local corner =
        Instance.new(
            "UICorner"
        )


    corner.CornerRadius =
        UDim.new(
            1,
            0
        )


    corner.Parent =
        toggle



    local knob =
        Instance.new(
            "Frame"
        )


    knob.Size =
        UDim2.new(
            0,
            26,
            0,
            26
        )


    knob.Position =
        value
        and UDim2.new(
            0,
            25,
            0,
            3
        )
        or
        UDim2.new(
            0,
            3,
            0,
            3
        )



    knob.BackgroundColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )


    knob.Parent =
        toggle



    local kc =
        Instance.new(
            "UICorner"
        )

    kc.CornerRadius =
        UDim.new(
            1,
            0
        )

    kc.Parent =
        knob




    toggle.MouseButton1Click:Connect(
        function()


            value =
                not value



            TweenService:Create(

                toggle,

                TweenInfo.new(
                    0.25,
                    Enum.EasingStyle.Quint
                ),

                {

                    BackgroundColor3 =
                        value
                        and iOS26_UI.Theme.Accent
                        or iOS26_UI.Theme.Off

                }

            ):Play()



            TweenService:Create(

                knob,

                TweenInfo.new(
                    0.25,
                    Enum.EasingStyle.Quint
                ),

                {

                    Position =
                        value
                        and UDim2.new(
                            0,
                            25,
                            0,
                            3
                        )
                        or
                        UDim2.new(
                            0,
                            3,
                            0,
                            3
                        )

                }

            ):Play()



            if config.Callback then

                config.Callback(
                    value
                )

            end


        end
    )


    return toggle

end





------------------------------------------------
-- Slider
------------------------------------------------

function iOS26_UI.CreateSlider(parent,config)


    config =
        config or {}



    local min =
        config.Min or 0


    local max =
        config.Max or 100


    local value =
        config.Default or min



    local frame =
        Instance.new(
            "Frame"
        )


    frame.Size =
        UDim2.new(
            0,
            220,
            0,
            30
        )


    frame.BackgroundTransparency =
        1


    frame.Parent =
        parent




    local bar =
        Instance.new(
            "Frame"
        )


    bar.Size =
        UDim2.new(
            1,
            0,
            0,
            8
        )


    bar.Position =
        UDim2.new(
            0,
            0,
            0.5,
            -4
        )


    bar.BackgroundColor3 =
        iOS26_UI.Theme.Off


    bar.Parent =
        frame



    local fill =
        Instance.new(
            "Frame"
        )


    fill.Size =
        UDim2.new(

            (value-min)
            /
            (max-min),

            0,

            1,

            0

        )


    fill.BackgroundColor3 =
        iOS26_UI.Theme.Accent


    fill.Parent =
        bar



    for _,v in pairs(
        {
            bar,
            fill
        }
    ) do


        local c =
            Instance.new(
                "UICorner"
            )


        c.CornerRadius =
            UDim.new(
                1,
                0
            )


        c.Parent =
            v


    end



    return frame

end



return iOS26_UI