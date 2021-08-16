#include <dragoneer2.h>
#include <OOP/OOP_.h>

#include <stdio.h>

DgnInterface( Mammal ) {
    void DgnMethod( Milk ) ( DgnSelf );
};

DgnInterface( Pet ) {
    char *DgnMethod( GetName ) ( DgnSelf );
    void DgnMethod( Speak ) ( DgnSelf, const char *message );
};

DgnInterface( Dog ) {
    char *DgnMethod( GetBreed ) ( DgnSelf );
    DgnInherits( Mammal )
    DgnInherits( Pet )
};

Implement_Dog( Husky );
Implement_Dog( Bulldog );

char *Husky_GetBreed ( void *self ) {
    return "Husky";
}

char *Bulldog_GetBreed ( void *self ) {
    return "Bulldog";
}

int main () {
    struct Dog dog1 = { .pVft = &Husky_Vft_Dog, .data = NULL };
    struct Dog dog2 = { .pVft = &Bulldog_Vft_Dog, .data = NULL };
    printf( "%s %s", Dog_GetBreed( dog1 ), Dog_GetBreed( dog2 ));
}