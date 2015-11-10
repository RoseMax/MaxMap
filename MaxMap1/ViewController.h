
#import <GoogleMaps/GoogleMaps.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Corelocation/Corelocation.h>
#import "CustomInforWindow.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate, NSURLConnectionDataDelegate>
{
    CLLocationManager *locationManager;
    
    
}
@property (nonatomic, retain)IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *buttonObject;
@property (weak, nonatomic) IBOutlet UIButton *placeButton;

-(IBAction)setMap:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *Googleview;
- (IBAction)getCurrentPlace:(id)sender;

@property (nonatomic, getter = isResultsLoaded)BOOL resultsLoaded;
@property (nonatomic, retain)NSURLConnection *urlConnection;
@property (nonatomic, retain)NSMutableData *reponseData;
@property (nonatomic, retain)NSMutableArray *locations;

@property (strong, nonatomic)NSMutableString *name;
@property (strong, nonatomic)NSMutableString *address;
@property (strong, nonatomic)UIImage *display;

@end

