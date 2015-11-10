

#import "ViewController.h"
@import GoogleMaps;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *addresslabel;
@end

@implementation ViewController{
    GMSMapView *gmapview;
    GMSPlacesClient *placesclient;
    GMSPlacePicker *placePicker;
}
@synthesize mapView;

int MarkerTag = 0;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    locationManager =[[CLLocationManager alloc]init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    return self;
}

 
-(IBAction)setMap:(id)sender{
    switch (((UISegmentedControl*)sender).selectedSegmentIndex) {
        case 0:
            mapView.mapType=MKMapTypeStandard;
            break;
        case 1:
            mapView.mapType=MKMapTypeSatellite;
            break;
        case 2:
            mapView.mapType=MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
   CLLocationCoordinate2D searchfrom = CLLocationCoordinate2DMake(40.741061, -73.989699);

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:searchfrom zoom:15];
    gmapview = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    gmapview.delegate =self;
    gmapview.myLocationEnabled=YES;
   self.view =gmapview;
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = searchfrom;
    marker.title=@"Flatiron building";
    marker.snippet = @"New York City";
    marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
    marker.map = gmapview;
    
    placesclient = [[GMSPlacesClient alloc]init];
    [gmapview addSubview:self.buttonObject];
    [gmapview addSubview:self.namelabel];
    [gmapview addSubview:self.addresslabel];
    [gmapview addSubview:self.placeButton];
    
    GMSMarker *london = [GMSMarker markerWithPosition:searchfrom];
    london.title = @"London";
    london.snippet = @"Population: 8,174,100";
    london.infoWindowAnchor = CGPointMake(0.5, 0.5);
    london.icon = [UIImage imageNamed:@"imgres"];
    london.map = gmapview;
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    NSLog(@"User Location: %f,%f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 250, 250);
    [self.mapView setRegion:region animated:YES];
    
}

- (IBAction)getCurrentPlace:(id)sender {
    [placesclient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil){
            NSLog(@"Pick Place Error %@", [error localizedDescription]);
            return;
        }
        self.namelabel.text =@"No Current Place";
        self.addresslabel.text = @" ";
        if (placeLikelihoodList!=nil){
            GMSPlace *place= [[[placeLikelihoodList likelihoods]firstObject]place];
            if (place != nil){
                self.namelabel.text = place.name;
                self.addresslabel.text = [[place.formattedAddress componentsSeparatedByString:@", " ]componentsJoinedByString:@"\n"];
                
                [self.view setNeedsDisplay];
            }
        }
    }];
}
- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
-(IBAction)pickPlace:(UIButton*)sender{
    //NOTE: JSON Get request for search
    NSURL *searchURL = [NSURL URLWithString:@"(GMS URL)"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL: searchURL];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSData *newresponse =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        NSDictionary *searchResults =[NSJSONSerialization JSONObjectWithData:newresponse options:0 error:nil];
        
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableArray *latArray =[[NSMutableArray alloc]init];
                NSMutableArray *lonArray =[[NSMutableArray alloc]init];
                
              
                
                
                NSArray *results = searchResults[@"results"];

                for(int i =0;i<[results count]; i++){
                    self.name =[[NSMutableString alloc]init];
                    self.address = [[NSMutableString alloc]init];
                    
  
                double lat = [results[i][@"geometry"][@"location"][@"lat"] doubleValue];
                double lon = [results[i][@"geometry"][@"location"][@"lng"] doubleValue];
                    
                NSString *icon = results[i][@"icon"];
                   self.name = results[i][@"name"];
                     self.address = results[i][@"vicinity"];
                [latArray addObject:[NSNumber numberWithDouble:lat]];
                [lonArray addObject:[NSNumber numberWithDouble:lon]];
                
                CLLocation *location =[[CLLocation alloc]initWithLatitude:[[latArray objectAtIndex:i]doubleValue] longitude:[[lonArray objectAtIndex:i]doubleValue]];
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
                    
                NSData *data2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:icon]];
                GMSMarker *searchMarker =[[GMSMarker alloc]init];
                
                searchMarker = [GMSMarker markerWithPosition:coordinate];
                searchMarker.position =CLLocationCoordinate2DMake([[latArray objectAtIndex:i]doubleValue], [[lonArray objectAtIndex:i]doubleValue]);
                searchMarker.icon=[UIImage imageWithData:data2];
                    searchMarker.icon = [self image:searchMarker.icon scaledToSize:CGSizeMake(30, 30)];
                    NSDictionary *searchMarkerInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.name,@"MarkerName",self.address,@"MarkerAddress",searchMarker.icon,@"MarkerImage", nil];
                    NSLog(@"%@",searchMarkerInfo);
                    searchMarker.userData = searchMarkerInfo;
                searchMarker.map =gmapview;
                    searchMarker.infoWindowAnchor = CGPointMake(.44f, .45f);
                     }
            });
}]
     resume];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker{
     CustomInforWindow *infoWindow = [[[NSBundle mainBundle]loadNibNamed:@"InfoWindow" owner:self options:nil]objectAtIndex:0];
    NSLog(@"%@", marker.userData);
    NSDictionary *currentMarker = (NSDictionary *) marker.userData;
    infoWindow.name.text = [currentMarker valueForKey:@"MarkerName"];
    infoWindow.address.text = [currentMarker valueForKey:@"MarkerAddress"];
    infoWindow.photo.image = [currentMarker valueForKey:@"MarkerImage"];
    return infoWindow;
}




@end
