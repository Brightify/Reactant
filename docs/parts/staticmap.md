StaticMap
=========

StaticMap is one of Reactant's components. It's purpose is to display map of selected `MKCoordinateRegion` as an image without any controls. StaticMap component is very efficient since it uses cache to store the map image and to retrieve it.

This component's `componentState` is `MKCoordinateRegion` and its `action` is `StaticMapAction` which is an enum with only one `case selected`,  that is propagated through `action` observable whenever the component's content are clicked.  
