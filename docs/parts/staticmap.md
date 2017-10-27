# StaticMap

StaticMap is one of Reactant's prebuilt components. To integrate it into your project, you need to add `StaticMap` subspec to your `Podfile`. To do so, open your `Podfile` in your favorite text editor and add the following line to your application's target:

```ruby
pod 'Reactant/StaticMap'
```

`StaticMap` is meant to be used wherever you want to display a map without letting the user control it. Were you to use the `MKMapView`, you would get noticeable lags when pushing a controller as `MKMapView` renders on main thread. `StaticMap` renders in background and presents a loaded image.

To render the map, we recommend using `MKMapSnapshotter`, and to cache the map we recommend a library called `Kingfisher`.

`StaticMap` has a `componentState` of type `MKCoordinateRegion`. This region specifies the visible part of the map. It also has an `action` of type `StaticMapAction`. This action is just an enum, having a single case `selected`. Whenever user taps on the map, `StaticMap` sends this `.selected` action to be handled.
