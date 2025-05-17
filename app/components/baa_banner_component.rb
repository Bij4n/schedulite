class BaaBannerComponent < ViewComponent::Base
  def initialize(tenant:)
    @tenant = tenant
  end

  def render?
    @tenant.baa_uploaded_at.blank?
  end

  def call
    tag.div(class: "rounded-2xl bg-amber-50 border border-amber-200 px-4 py-3 mb-4") do
      safe_join([
        tag.div(class: "flex items-center gap-2") do
          safe_join([
            tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "h-5 w-5 text-amber-600") do
              tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z")
            end,
            tag.p("Business Associate Agreement required", class: "text-sm font-semibold text-amber-800")
          ])
        end,
        tag.p("A signed BAA must be in place before handling real patient data. Contact your administrator to upload the agreement.", class: "mt-1 text-xs text-amber-700")
      ])
    end
  end
end
